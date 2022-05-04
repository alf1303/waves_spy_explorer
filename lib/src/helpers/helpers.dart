import 'dart:convert';

import 'package:waves_spy/src/constants.dart';
import 'package:http/http.dart' as http;

import '../models/asset.dart';
import '../providers/transaction_provider.dart';

DateTime timestampToDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date;
}

String getTypeName(int type) {
    switch(type) {
        case 4:
            return "Asset Transfer";
        case 6:
            return "Asset Burn";
        case 7:
            return "Exchange";
        case 11:
            return "Mass Payment";
        case 16:
            return "Invoke Script";
        default:
            return "Unknown";
    }
}

getTransfers(String addr, dynamic jsonD, Map<String, double> resDict) {
    var transfers = jsonD["stateChanges"]["transfers"];
    for (dynamic el in transfers) {
        double amount = el["amount"] ?? 0;
        if (el["address"] == addr) {
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
    List<dynamic> invokes = jsonD["stateChanges"]["invokes"];
        for (var inv in invokes) {
            getTransfers(addr, inv, resDict);
        }
}

var assetsGlobal = <String, Asset>{};

Future<Asset> fetchAssetInfo(String? id) async{
    var data = <String, dynamic>{};
    if(id == null || id == "WAVES") {
        data["assetId"] = "WAVES";
        data["name"] = "WAVES";
        data["decimals"] = 8;
    } else {
        var resp = await http.get(Uri.parse("$nodeUrl/assets/details/$id"));
        data = jsonDecode(resp.body);
    }
    if (data.containsKey("error")) {
        throw ("Can not fetch asset details data");
    }
    return Asset(data["assetId"], data["name"], data["decimals"]);
}

Future<List<Asset?>>? getAssetInfo(String id) async{
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

parseTransactionType(Map<String, dynamic> td)  {
    final _transactionProvider = TransactionProvider();
    Map<String, double> payment = {};
    Map<String, double> transfers = {};
    var p = <String, dynamic>{};
    p['exchPriceAsset'] = " ";
    switch(td['type']) {
        case 16:
            p["dApp"] = td["dApp"];
            p["dAppName"] = getAddrName(p["dApp"]);
            p["function"] = td["call"]["function"];

            for (var element in td["payment"]) {
                final assetId = element["assetId"] ?? "WAVES";
                payment[assetId] = element["amount"];
            }
            getTransfers(_transactionProvider.curAddr, td, transfers);
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
            p["header"] = ["exchange"];
            p["exchPriceAsset"] = amountAsset;
            break;
    }
    p['transfers'] = transfers;
    p['payment'] = payment;
    return p;
}