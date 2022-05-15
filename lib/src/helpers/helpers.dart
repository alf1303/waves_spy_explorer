import 'dart:convert';
import 'dart:html';

import 'package:waves_spy/src/constants.dart';
import 'package:http/http.dart' as http;

import '../models/asset.dart';
import '../providers/transaction_provider.dart';

Map<String, Asset> assetsGlobal = {};

DateTime timestampToDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date;
}

Asset? getAssetFromLoaded(String id) {
    if (assetsGlobal.containsKey(id)) {
        return assetsGlobal[id];
    } else {
        return null;
    }
}

int dateToTimestamp(DateTime? date) {
    if (date == null) {
        print("--- helpers.dart dateToTimestamp: input date is null");
    }
    final ts = date == null ? 0 : date.millisecondsSinceEpoch;
    return ts;
}

String getTypeName(int type) {
    switch(type) {
        case 3:
            return "Issue";
        case 4:
            return "Asset Transfer";
        case 5:
            return "Reissue";
        case 6:
            return "Asset Burn";
        case 7:
            return "Exchange";
        case 8:
            return "Lease";
        case 9:
            return "Lease cancel";
        case 10:
            return "Alias";
        case 11:
            return "Mass Payment";
        case 16:
            return "Invoke Script";
        case 12:
            return "Data";
        case 13:
            return "Set Script";
        case 14:
            return "Set Sponsorship";
        case 15:
            return "Set Asset Script";
        case 17:
            return "Update Asset Script";
        default:
            return "Unknown";
    }
}

Future<Asset> fetchAssetInfo(String? id) async{
    var data = <String, dynamic>{};
    // print("fetching: " + id!);
    if(id == "WAVES") {
        data["assetId"] = "WAVES";
        data["name"] = "WAVES";
        data["decimals"] = 8;
        data['description'] = "Waves blockchain core token";
        data['reissuable'] = true;
        data['scripted'] = false;
    } else {
        var resp = await http.get(Uri.parse("$nodeUrl/assets/details/$id"));
        data = jsonDecode(resp.body);
    }
    if (data.containsKey("error")) {
        throw ("Can not fetch asset details data");
    }
    return Asset(data["assetId"], data["name"], data["decimals"], data['description'], data['reissuable'], data["scripted"]);
}

Future<List<Asset?>>? getAssetInfoLabel(String id) async{
    Asset? asset;
    List<String> ids = id.split(".|.");
    if (assetsGlobal.containsKey(ids[0])) {
        asset = assetsGlobal[ids[0]];
    } else {
        asset = await fetchAssetInfo(ids[0]);
        assetsGlobal[ids[0]] = asset;
    }
    Asset? priceAsset;
    if (ids[1] != " ") {
        if (assetsGlobal.containsKey(ids[1])) {
            priceAsset = assetsGlobal[ids[1]];
        } else {
            priceAsset = await fetchAssetInfo(ids[1]);
            assetsGlobal[ids[1]] = priceAsset;
        }
    }
    return [asset, priceAsset];
}

Future<void> getMassAssetsInfo(Map<String, dynamic> ids) async{
    final keys = ids.keys.toList();
    bool stop = false;
    int start = 0;
    while (!stop) {
      String tmpstr = "";
      String tmpsepar = "";
      for (int i = start; i < keys.length; i++) {
          if(i == keys.length - 1) {
              stop = true;
          }
          if(keys[i] != "WAVES") {
              if((tmpstr.length + keys[i].length) >= 2048) {
                  start = i;
                  break;
              }
              tmpstr += tmpsepar + keys[i];
              if (tmpsepar == "") {
                  tmpsepar = "&id=";
              }
          }
      }

      // for (var id in keys) {
      //     if (id != "WAVES") {
      //       tmpstr += tmpsepar + id;
      //       if (tmpsepar == "") {
      //           tmpsepar = "&id=";
      //       }
      //     }
      // }



      var resp = await http.get(Uri.parse("$nodeUrl/assets/details?id=$tmpstr"));
      if (resp.statusCode == 200) {
        List<dynamic> assetDetails = jsonDecode(resp.body);
        for (var ass in assetDetails) {
            if (!assetsGlobal.containsKey(ass['assetId'])) {
                // print(ass);
                Asset a = Asset(ass['assetId'], ass['name'], ass['decimals'], ass['description'], ass['reissuable'], ass["scripted"]);
                assetsGlobal[a.id] = a;
            }
        }
      } else {
          throw("Failed to load assets details: " + resp.body);
      }
    }
}

getTransfers({required bool isDapp, required String sender, required String curAddr, dynamic data, required Map<String, double> resDict}) {
    var transfers = data["stateChanges"]["transfers"];
    for (dynamic el in transfers) {
        double amount = el["amount"] ?? 0;
        // bool condition = isDapp ?
        if (el["address"] == sender || (!isDapp && el["address"] == curAddr)) {
            final assetId = el["asset"] ?? "WAVES";
            if (resDict.containsKey(assetId)) {
                double prevAm = resDict[assetId] ?? 0;
                resDict[assetId] = prevAm + amount;
            }
            else {
                resDict[assetId] = el["amount"];
            }
        }
        }
    List<dynamic> invokes = data["stateChanges"]["invokes"];
        for (var inv in invokes) {
            getTransfers(isDapp: isDapp, sender: sender, curAddr: curAddr, data: inv, resDict: resDict);
        }
        // print(resDict);
}

parseTransactionType(Map<String, dynamic> td)  {
    final _transactionProvider = TransactionProvider();
    Map<String, double> payment = {};
    Map<String, double> transfers = {};
    var p = <String, dynamic>{};
    p['exchPriceAsset'] = " ";
    p["sender"] = td["sender"];
    switch(td['type']) {
        case 16:
            p["dApp"] = td["dApp"];
            p["dAppName"] = getAddrName(p["dApp"]);
            p["function"] = td["call"]["function"];

            for (var element in td["payment"]) {
                final assetId = element["assetId"] ?? "WAVES";
                payment[assetId] = element["amount"];
            }
            getTransfers(isDapp: td["dApp"] == _transactionProvider.curAddr, sender: td["sender"], curAddr: _transactionProvider.curAddr, data: td, resDict: transfers);
            p["header"] = "invoke";
            break;
        case 4:
            final assetId = td["assetId"] ?? "WAVES";
            if (td["recipient"] == _transactionProvider.curAddr) {
                p["anotherAddr"] = td["sender"];
                p["name"] = getAddrName(p["anotherAddr"]);
                p["direction"] = "IN";
                transfers[assetId] = td["amount"];
            } else {
                p["anotherAddr"] = td["recipient"];
                payment[assetId] = td["amount"];
                p["direction"] = "OUT";
            }
            p["header"] = "transfer";
            break;
        case 11:
            final assetId = td["assetId"] ?? "WAVES";
            p["anotherAddr"] = td["sender"];
            p["name"] = getAddrName(p["anotherAddr"]);
            List<dynamic> trtr = td["transfers"];
            trtr.forEach((el) {
                if(el["recipient"] == _transactionProvider.curAddr) {
                    if(transfers.containsKey(td["assetId"])) {
                        transfers[assetId] = transfers[assetId]! + el["amount"];
                    } else {
                        transfers[assetId] = el["amount"];
                    }
                }
            });
            p["header"] = "massTransfer";
            break;
        case 6:
            final assetId = td["assetId"] ?? "WAVES";
            payment[assetId] = td["amount"];
            p["header"] = "burn";
            break;
        case 7:
            p["dApp"] = td["sender"];
            p["dAppName"] = getAddrName(td["sender"]);
            final buy = td["order1"];
            final sell = td["order2"];
            final amountAsset = buy["assetPair"]["amountAsset"] ?? "WAVES";
            final priceAsset = buy["assetPair"]["priceAsset"] ?? "WAVES";
            p['sellOrder'] = sell["amount"];
            p['buyOrder'] = buy["amount"];
            p['amountAsset'] = amountAsset;
            p['priceAsset'] = priceAsset;
            p['seller'] = sell['sender'];
            p['buyer'] = buy['sender'];
            double amount = sell['amount'] < buy['amount'] ? sell['amount'] : buy['amount'];
            if(buy["sender"] == _transactionProvider.curAddr) {
                transfers[amountAsset] = amount;
                double val = amount*buy["price"];
                payment[priceAsset] = val;
            }
            if(sell["sender"] == _transactionProvider.curAddr) {
                double val = amount*sell["price"];
                transfers[priceAsset] = val;
                payment[amountAsset] = amount;
            }
            // print(transfers)
            p["header"] = "exchange";
            p["exchPriceAsset"] = amountAsset;
            break;
    }
    p['transfers'] = transfers;
    p['payment'] = payment;
    return p;
}