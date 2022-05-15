import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/progress_bars_provider.dart';

import '../models/asset.dart';

class TransactionProvider extends ChangeNotifier {
  static final TransactionProvider _instance = TransactionProvider._internal();

  factory TransactionProvider() {
    return _instance;
  }

  TransactionProvider._internal();

  final progressProvider = ProgressProvider();
  String curAddr = "";
  String afterGlob = "";
  int limit = 20;

  String header = "";
  String filterData = "";

  List<dynamic> allTransactions = List.empty(growable: true);
  List<dynamic> filteredTransactions = List.empty(growable: true);

  List<dynamic> nft = List.empty(growable: true);
  List<dynamic> assets = List.empty(growable: true);
  List<dynamic> data = List.empty(growable: true);
  String script = "";
  dynamic wavesBalance = {
    "regular": 0,
    "generating": 0,
    "available": 0,
    "effective": 0};

  void createInfo() {
    final _filterProvider = FilterProvider();
    header = "Loaded transactions: ${allTransactions.length}, Filtered: ${filteredTransactions.length}";
    filterData = _filterProvider.createFilterData();
  }

  Future<void> setCurrAddr(String address) async {
    curAddr = address;
    afterGlob = "";
    allTransactions.clear();
    await getTransactions(address: curAddr);
    await getAssets(curAddr);
    // await getNft(curAddr); //implement
    // await getData(curAddr); //implement
    // await getScript(curAddr); //implement
    notifyListeners();
  }

  Future<void> getMoreTransactions() async{
    await getTransactions(address: curAddr, after: true);
  }

  Future<void> getTransactions({required String address, bool? after}) async {
    if (curAddr.isNotEmpty) {
      final filterProvider = FilterProvider();
      bool stopDate = false;
      progressProvider.start();
      List<dynamic> res = List.empty(growable: true);
      while (!stopDate) {
        String afterId = after == null ? "" : afterGlob;
        after = true;
        var resp = await http.get(Uri.parse("$nodeUrl/transactions/address/$address/limit/$limit?after=$afterId"));
        // print(resp.body);
        // print("");
        if (resp.statusCode == 200) {
          final json = jsonDecode(resp.body);
          res = json[0];
          print("Loaded: " + res.length.toString());
          if(res.isEmpty) {
            print("--- TransactionProvider getTransactions() empty transactions list got");
          }
          var lastTrans = res[res.length - 1];
          afterGlob = lastTrans["id"];
          final curFromDateTs = dateToTimestamp(filterProvider.from);
          stopDate = lastTrans["timestamp"] < curFromDateTs || curFromDateTs == 0;
          // print("LastTrans: $afterGlob, trts: ${lastTrans["timestamp"]}, curFromDateTs: $curFromDateTs");
        } else {
          throw("Failed to load transactions list\n" + resp.body);
        }
      
        if (after == "") {
          allTransactions = res;
        } else {
          allTransactions.addAll(res);
        }
      }
      final ids = await extractAssets(res);
      await getMassAssetsInfo(ids);
      fillTransactionsWithAssetsNames(res);
      
      filteredTransactions = allTransactions;
      // print("Loaded ${allTransactions.length}, last: $afterGlob");
      
      filterTransactions();
      // JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      // for (var value in allTransactions) {
      //   print(encoder.convert(value));
      // }
      // allTransactions = allTransactions.where((element) => element["type"] == 16).toList();
      progressProvider.stop();
    }
  }

  // Loop through transactions and find all assets ids and addresses present in transaction
  // create sets in each transaction json and global set(for next step - fetching names)
  Future<Map<String, String>> extractAssets(List<dynamic> transactions) async {
    final assetsLocalIds = <String, String>{};
    for (var tr in transactions) {
      final transAssetsMap = <String, String>{};
      final trAddressesMap = <String, String>{};
      int type = tr["type"];

      if (tr.containsKey("sender")) {
        trAddressesMap['sender'] = getAddrName(tr['sender']);
      }

      tr.containsKey("dApp") ?
      trAddressesMap[tr["dApp"]] = getAddrName(tr["dApp"]) : {};

      // transfer, massTransfer, burn
      if (type == 4 || type == 11 || type == 6) {
        String assetId = tr["assetId"] ?? "WAVES";
        transAssetsMap[assetId] = assetId == "WAVES" ? "WAVES" : "";
      }

      // invokeScript
      if (type == 16) {
        List<dynamic> payment = tr["payment"];
        for (var pay in payment) {
          String assetId = pay["assetId"] ?? "WAVES";
          transAssetsMap[assetId] = assetId == "WAVES" ? "WAVES" : "";
        }
      }

      //invokeScript
      if (type == 16) {
        List<dynamic> transfers = tr["stateChanges"]["transfers"];
        for (var pay in transfers) {
          String asset = pay["asset"] ?? "WAVES";
          transAssetsMap[asset] = asset == "WAVES" ? "WAVES" : "";
          trAddressesMap[pay["address"]] = getAddrName(pay["address"]);
        }
      }

      // exchange
      if (type == 7) {
        final assId = tr['order1']['assetPair']['amountAsset'] ?? "WAVES";
        final prassId = tr['order1']['assetPair']['priceAsset'] ?? "WAVES";
        transAssetsMap[assId] = "";
        transAssetsMap[prassId] = "";
        final seller = tr["order2"]["sender"];
        final buyer = tr["order1"]["sender"];
        trAddressesMap[seller] = getAddrName(seller);
        trAddressesMap[buyer] = getAddrName(buyer);
      }

      tr["addresses"] = trAddressesMap;
      tr["assetsIds"] = transAssetsMap;
      tr["addressesNames"] = trAddressesMap.values.join(",");
      assetsLocalIds.addAll(transAssetsMap);
    }
    return assetsLocalIds;
  }

  Future<void> getAssets(String address) async {
    var res = <dynamic>[];
    var resp = await http.get(Uri.parse("$nodeUrl/assets/balance/$address"));
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      // print(resp.body);
      res = json["balances"];
      assets = res;
    } else {
      throw("Failed to load assets list. \n" + resp.body);
    }
  }

  Future<void> getNft(String address) async {}

  getData(String address) {
  }

  getScript(String address) {}

  void fillTransactionsWithAssetsNames(List<dynamic> res) {
    for (var tr in res) {
      Map<String, String> assets = tr["assetsIds"];
      for (String e in assets.keys) {
        assets[e] = assetsGlobal.containsKey(e) ? assetsGlobal[e]!.name : "";
      }
      tr["assetsNames"] = assets.values.join(",");
    }
  }

  void filterTransactions() {
    final filterProvider = FilterProvider();
    List<dynamic> datedTransactions = List.from(allTransactions);
    print("Transactions loaded: " + datedTransactions.length.toString());
    if (filterProvider.to != null) {
      int toTS = dateToTimestamp(filterProvider.to!);
      datedTransactions = datedTransactions.where((tr) => tr["timestamp"] < toTS).toList();
    }
    print("Transactions to: " + datedTransactions.length.toString());
    if (filterProvider.from != null) {
      int fromTS = dateToTimestamp(filterProvider.from!);
      datedTransactions = datedTransactions.where((tr) => tr["timestamp"] >= fromTS).toList();
    }
    print("Transactions from: " + datedTransactions.length.toString());
    if (filterProvider.fType != 0) {
      filteredTransactions = datedTransactions
          .where((tr) => tr["type"] == filterProvider.fType)
          .toList();
    } else {
      filteredTransactions = datedTransactions;
    }
    // print("*** 1");
    if(filterProvider.fType == 16) {
      filteredTransactions = filteredTransactions.where((tr) => tr["call"]["function"].toLowerCase().contains(filterProvider.functName.toLowerCase())).toList();
    }
    final trToFilter = filterProvider.isFiltered() ? filteredTransactions : datedTransactions;

    // print("*** 2");
    // trToFilter.forEach((element) {
    //   // print(element["id"].toString() + ": " + element["assetsNames"]);
    //   print("id: ${element.containsKey("id")}, assetsNames: ${element.containsKey("assetsNames")}");
    // });
    // print("*** 3");
    // print("**************");
    filteredTransactions = trToFilter.where((tr) => tr["assetsNames"].toLowerCase().contains(filterProvider.assetName.toLowerCase())).toList();
    // print("*** 4");
    createInfo();
    notifyListeners();
  }
}



