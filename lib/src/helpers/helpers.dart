import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:waves_spy/src/charts/puzzle/puzzle_burn.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:waves_spy/src/main_page.dart';
import 'package:waves_spy/src/models/stats_item.dart';
import 'package:waves_spy/src/providers/asset_provider.dart';
import 'package:waves_spy/src/providers/data_script_provider.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/label_provider.dart';
import 'package:waves_spy/src/providers/nft_provider.dart';
import 'package:waves_spy/src/providers/stats_provider.dart';
import 'package:waves_spy/src/providers/transaction_details_provider.dart';

import '../models/asset.dart';
import '../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

final transactionProvider = TransactionProvider();
final assetProvider = AssetProvider();
final nftProvider = NftProvider();
final dataProvider = DataScriptProvider();
final statsProvider = StatsProvider();
final labelProvideer = LabelProvider();
final transactionDetailsProvider = TransactionDetailsProvider();
final filterProvider = FilterProvider();

double fSize = 12; // stored regular fontSize for calling without context
double smallFSize = 10; // stored smaller fontSize for calling without context
bool isNarr = false;

Future<void> loadMoreTr() async {
    await transactionProvider.getMoreTransactions();
}

Future<void> loadAllTr() async {
    await transactionProvider.getAllTransactions();
}
String getFormattedDate(DateTime? dt) {
    return dt != null ? DateFormat('yyyy-MM-dd kk:mm').format(dt) : "nul";
}

Map<String, Asset> assetsGlobal = {};

String calcExchPrice(Map<String, dynamic> tr) {
    String result = "----";
    Map<String, double> assets = {
    ...tr["additional"]["inAssetsIds"],
        ...tr["additional"]["outAssetsIds"]
  };
  // print("Whatt");
    String amount_id = tr["order1"]["assetPair"]["amountAsset"] ?? "WAVES";
    String base_id = tr["order1"]["assetPair"]["priceAsset"] ?? "WAVES";
    // Asset? amAss = getAssetFromLoaded(amount_id);
    // Asset? baseAss = getAssetFromLoaded(base_id);
    int am_decimals = getAssetDecimals(amount_id);
    int base_decimals = getAssetDecimals(base_id);
    double amount_amount = assets[amount_id] ?? 1;
    double base_amount = assets[base_id] ?? 0;
    final decims = 8 + base_decimals - am_decimals;
    double price = ((base_amount / pow(10, base_decimals)) / (amount_amount / pow(10, am_decimals)))/pow(10, (6-decims).abs());
    return "${price.toStringAsFixed(2)} ${tr["additional"]["assetsIds"][base_id]}/${tr["additional"]["assetsIds"][amount_id]}";
}

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

int getAssetDecimals(String id) {
    if (id == "WAVES") {
        return 8;
    } else {
        Asset? ass = getAssetFromLoaded(id);
        if (ass == null) {
            return 1;
        } else {
            return ass.decimals;
        }
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

List<Asset?>? getAssetInfoLabelLocal(String id) {
    Asset? asset;
    List<String> ids = id.split(".|.");
    if (assetsGlobal.containsKey(ids[0])) {
        asset = assetsGlobal[ids[0]];
    } else {
        // asset = await fetchAssetInfo(ids[0]);
        // assetsGlobal[ids[0]] = asset;
    }
    Asset? priceAsset;
    if (ids[1] != " ") {
        if (assetsGlobal.containsKey(ids[1])) {
            priceAsset = assetsGlobal[ids[1]];
        } else {
            // priceAsset = await fetchAssetInfo(ids[1]);
            // assetsGlobal[ids[1]] = priceAsset;
        }
    }
    return [asset, priceAsset];
}

Future<void> getMassAssetsInfo(Map<String, dynamic> ids) async {
    List<dynamic> assetDetails = await getMassAssets(ids);
    for (var ass in assetDetails) {
            if (!assetsGlobal.containsKey(ass['assetId'])) {
                Asset a = Asset(ass['assetId'], ass['name'], ass['decimals'], ass['description'], ass['reissuable'], ass["scripted"]);
                assetsGlobal[a.id] = a;
            }
    }
}

Future<List<dynamic>> getMassAssets(Map<String, dynamic> ids) async{
    final keys = ids.keys.toList();
    bool stop = false;
    int start = 0;
    List<dynamic> assetDetails = List.empty(growable: true);
    while (!stop) {
      String tmpstr = "";
      String tmpsepar = "";
      for (int i = start; i < keys.length+1; i++) {
          if(i == keys.length ) {
              stop = true;
              break;
          }
          if(keys[i] != "WAVES") {
              final lll = (tmpstr.length + keys[i].length);
              if(lll >= 1948) {
                  start = i;
                  break;
              }
              tmpstr += tmpsepar + keys[i];
              if (tmpsepar == "") {
                  tmpsepar = "&id=";
              }
          }
      }
      var resp = await http.get(Uri.parse("$nodeUrl/assets/details?id=$tmpstr"));
      if (resp.statusCode == 200) {
        List<dynamic> tmp = jsonDecode(resp.body);
        bool err = false;
        for(var el in tmp) {
            if(el.containsKey("error")) {
                stop = true;
                print("Error: ${el.toString()} $tmpstr");
                err = true;
                break;
            }
        }
        if(!err) {
            assetDetails.addAll(jsonDecode(resp.body));
        }
      } else {
          print("Failed to load assests details: " + resp.body);
          print("Input tmpstr: " + tmpstr);
          // throw("Failed to load assets details: " + resp.body);
      }
    }
    return assetDetails;
}

getTransfers({required bool isDapp, required String sender, required String curAddr, dynamic data, required Map<String, double> resDict}) {
    var transfers = data["stateChanges"]["transfers"];
    for (dynamic el in transfers) {
        double amount = el["amount"] ?? 0;
        // bool condition = isDapp ?
        if ((isDapp && el["address"] == sender) || (!isDapp && isCurrentAddr(el["address"]))) {
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
    p["fail"] = td["additional"]["fail"];
    switch(td['type']) {
        case 16:
            p["dApp"] = td["dApp"];
            p["dAppName"] = getAddrName(p["dApp"]);
            p["function"] = td["call"]["function"];

            for (var element in td["payment"]) {
                final assetId = element["assetId"] ?? "WAVES";
                if (isCurrentAddr(td["sender"]) ||  isCurrentAddr(td["dApp"])) {
                  payment[assetId] = element["amount"];
                }
            }
            getTransfers(isDapp: isCurrentAddr(td["dApp"]), sender: td["sender"], curAddr: _transactionProvider.curAddr, data: td, resDict: transfers);
            p["header"] = "invoke";
            break;
        case 4:
            final assetId = td["assetId"] ?? "WAVES";
            if (isCurrentAddr(td["recipient"])) {
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
                if(isCurrentAddr(el["recipient"])) {
                    if(transfers.containsKey(td["assetId"])) {
                        transfers[assetId] = transfers[assetId]! + el["amount"];
                    } else {
                        transfers[assetId] = el["amount"];
                    }
                }
            });
            if(isCurrentAddr(td["sender"])) {
                payment[assetId] = td["totalAmount"];
            }
            p["header"] = "massTransfer";
            break;
        case 3:
            p["header"] = "issue";
            p["quantity"] = td["quantity"];
            p["assetId"] = td["assetId"];
            break;
        case 5:
            p["header"] = "reissue";
            p["quantity"] = td["quantity"];
            p["assetId"] = td["assetId"];
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
            String orderDirection = sell['amount'] < buy['amount'] ? "sell" : "buy";
            if(isCurrentAddr(buy["sender"])) {
                transfers[amountAsset] = amount;
                double val = amount*buy["price"];
                payment[priceAsset] = val;
            }
            if(isCurrentAddr(sell["sender"])) {
                double val = amount*sell["price"];
                transfers[priceAsset] = val;
                payment[amountAsset] = amount;
            }
            if(isCurrentAddr(td["sender"])) {
                if(orderDirection == "sell") {
                    payment[amountAsset] = amount;
                    transfers[priceAsset] = amount*sell["price"];
                } else {
                    payment[priceAsset] = amount*sell["price"];
                    transfers[amountAsset] = amount;
                }

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

bool isPresentData(String label) {
    switch (label) {
        case "trans":
            return transactionProvider.allTransactions.isNotEmpty;
        case "assets":
            return assetProvider.assets.isNotEmpty;
        case "nfts":
            return nftProvider.nfts.isNotEmpty;
        case "data":
            return dataProvider.data.isNotEmpty;
        case "script":
            return dataProvider.script.isNotEmpty;
        default:
            return false;
    }
}

int getDucksCount() {
    throw("NOT IMPLEMENTED");
    // return nftProvider.nfts.where((nft) => nft["name"].contains("DUCK") && nft["issuer"] == "3PDVuU45H7Eh5dmtNbnRNRStGwULA7NY6Hb").toList().length;
}

void setDucksStatsData() {
    statsProvider.freeDucksCount = nftProvider.nfts.where((nft) => nft.isDuck && !nft.isFarming).toList().length;
    statsProvider.stakedDucksCount = nftProvider.nfts.where((nft) => nft.isDuck && nft.isFarming).toList().length;
    statsProvider.jediDucksCount = nftProvider.nfts.where((nft) => nft.isDuck && nft.isDjedi).toList().length;
}

Future<String> fetchAddrByAlias(String alias) async{
    String result = "";
    final String ali = alias.substring(8);
    // print("Alias: $ali");
    var resp = await http.get(Uri.parse("$nodeUrl/alias/by-alias/$ali"));
    if (resp.statusCode == 200) {
        result = jsonDecode(resp.body)["address"];
    } else {

        showSnackError("Cannot fetch address by alias: ${resp.body}, $alias");
        print("Cannot fetch address by alias: ${resp.body}");
    }
    return result;

}

showSnackError(String msg) {
    messengerKey.currentState?.showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade200,
        content: Text(msg),
        duration: const Duration(seconds: 7),
        action: SnackBarAction(
            textColor: Colors.black,
            label: 'CLOSE',
            onPressed: () {

            },
        ),
    ));
}

showSnackErrorPuz(String msg) {
    messengerKeyPuz.currentState?.showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade200,
        content: Text(msg),
        duration: const Duration(seconds: 7),
        action: SnackBarAction(
            textColor: Colors.black,
            label: 'CLOSE',
            onPressed: () {

            },
        ),
    ));
}

showSnackMsg({required String msg, int? duration}) {
    final dur = duration ?? 6;
    messengerKey.currentState?.showSnackBar(SnackBar(
        // backgroundColor: Colors.red.shade200,
        content: Text(msg),
        duration: Duration(seconds: dur),
        action: SnackBarAction(
            textColor: Colors.black,
            label: 'CLOSE',
            onPressed: () {

            },
        ),
    ));
}

showSnackMsgPuz({required String msg, int? duration}) {
    final dur = duration ?? 6;
    messengerKeyPuz.currentState?.showSnackBar(SnackBar(
        // backgroundColor: Colors.red.shade200,
        content: Text(msg),
        duration: Duration(seconds: dur),
        action: SnackBarAction(
            textColor: Colors.black,
            label: 'CLOSE',
            onPressed: () {

            },
        ),
    ));
}

bool isCurrentAddr(String value) {
    bool alias = false;
    bool addr = false;
    if(transactionProvider.aliases.isNotEmpty) {
        alias = transactionProvider.aliases.contains(value);
    }
    addr = transactionProvider.curAddr == value;
    return alias || addr;
}

int getLoadedItemsCount(String label) {
    int result = 0;
    switch (label) {
        case "trans":
            result = transactionProvider.allTransactions.length;
            break;
        case "assets":
            result =  assetProvider.assets.length;
            break;
        case "nfts":
            result = nftProvider.nfts.length;
            break;
        case "data":
            result =  dataProvider.data.length;
            break;
        case "script":
            break;
    }
    return result;
}

bool allTransactionsLoaded() {
    return transactionProvider.allTransactionsLoaded;
}

void collectDucksStats(Map<String, dynamic> tr) {
    final function = tr["call"]["function"];
    switch (function) {
        case "startDuckHatching":
            processDuckHatch(tr);
            break;
        case "startDuckBreeding":
            processDuckBreed(tr);
            break;
        case "initRebirth":
            processRebirth(tr);
            break;
        case "buyPerch":
            processBuyPerch(tr);
            break;
        case "finishRebirth":
            calculateRebirthResults(tr);
            break;
    }
}

void processDuckHatch(Map<String, dynamic> tr) {
    // print(tr);
    const String label = "Ducks hatched";
    const int count = 1;
    double amount = 0;
    if (tr["payment"].length > 0) {
        amount = tr["payment"][0]["amount"];
    }
    statsProvider.updateDuckStats(label, count, amount);
}

void processDuckBreed(Map<String, dynamic> tr) {
    const String label = "Ducks breeded";
    const int count = 1;
    double amount = 0;
    statsProvider.updateDuckStats(label, count, amount);
}

void processRebirth(Map<String, dynamic> tr) {
    const String label = "Ducks reborned";
    const int count = 1;
    double amount = 0;
    final payment = tr["payment"];
    for(var el in payment) {
        if(el["assetId"] == "C1iWsKGqLwjHUndiQ7iXpdmPum9PeCDFfyXBdJJosDRS") {
            amount = el["amount"];
        }
    }
    statsProvider.updateDuckStats(label, count, amount);
}

void processBuyPerch(Map<String, dynamic> tr) {
    const String label = "Perches purchased";
    const int count = 1;
    double amount = 0;
    if (tr["payment"].length > 0) {
        amount = tr["payment"][0]["amount"];
    }
    statsProvider.updateDuckStats(label, count, amount);
}

void calculateRebirthResults(Map<String, dynamic> tr) {
    final invokes = tr["stateChanges"]["invokes"];
    if (invokes.isNotEmpty) {
        if(invokes[0]["call"]["function"] == "addFreePerch") {
            statsProvider.updateRebirthResults("perches");
        }
        if(invokes[0]["call"]["function"] == "issueFreeDuckling") {
            statsProvider.updateRebirthResults("ducklings");
        }
        if(invokes[0]["call"]["function"] == "issueFreeDuck") {
            statsProvider.updateRebirthResults("Genesis ducks");
        }
    } else {
        statsProvider.updateRebirthResults("ZerO");
    }
}

void setLabelAddr() {
    labelProvideer.isAddressPresent = true;
    labelProvideer.notify();
}

void addAdditionalToTransactionDetails() {
    transactionDetailsProvider.setFullTransaction();
}

void setHighliteFlag() {
    filterProvider.highlightTradeAccs = true;
    filterProvider.notifyListeners();
}

double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
}

double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
}

bool isPortrait(BuildContext context) {
    return getHeight(context) > getWidth(context);
}

double getFontSize(BuildContext context) {
    final ff = getWidth(context)*0.009;
    fSize = ff >= 10 ? ff : 10;
    smallFSize = ff >= 5 ? ff*0.85 : 5;
    isNarr =  getWidth(context) <= 1280;
    return fSize;
}

double getSmallFontSize(BuildContext context) {
    final ff = getFontSize(context);
    smallFSize = ff >= 5 ? ff*0.85 : 5;
    isNarr =  getWidth(context) <= 1280;
    return smallFSize;
}

double getIconSize(BuildContext context) {
    return getFontSize(context)*1.6;
}

bool isNarrow(BuildContext context) {
    isNarr =  getWidth(context) <= 1280;
    return isNarr;
}

double getLastFontSize() {
    return fSize;
}

double getLastSmallFontSize() {
    return smallFSize;
}

bool lastIsNarrow() {
    return isNarr;
}

void copyToClipboard(String str) {
    Clipboard.setData(ClipboardData(text: str));
    showSnackMsg(msg: "copied: $str", duration: 3);
}

void copyToClipboardPuz(String str) {
    Clipboard.setData(ClipboardData(text: str));
    showSnackMsgPuz(msg: "copied: $str", duration: 3);
}

Future<String> decodeScript(String script) async{
    String ftf = script.toString().substring(7);
    var decoded = await http.post(Uri.parse("$nodeUrl/utils/script/decompile"), body: ftf);
    if(decoded.statusCode == 200) {
        final jsn = jsonDecode(decoded.body);
        return jsn["script"];
    } else {
        return "Error";
        // throw("Cant fetch decompiled script: " + decoded.body);
    }
}

