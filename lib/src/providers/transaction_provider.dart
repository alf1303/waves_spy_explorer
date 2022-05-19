import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/asset_provider.dart';
import 'package:waves_spy/src/providers/data_script_provider.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/nft_provider.dart';
import 'package:waves_spy/src/providers/progress_bars_provider.dart';

import '../models/asset.dart';

class TransactionProvider extends ChangeNotifier {
  static final TransactionProvider _instance = TransactionProvider._internal();

  factory TransactionProvider() {
    return _instance;
  }

  TransactionProvider._internal();

  final progressProvider = ProgressProvider();
  final assetProvider = AssetProvider();
  final nftProvider = NftProvider();
  final dataScriptProvider = DataScriptProvider();
  String curAddr = "";
  String afterGlob = "";
  String afterGlobNft = "";
  int limit = 500;
  int limitNft = 1000;

  String header = "";
  String filterData = "";

  List<dynamic> allTransactions = List.empty(growable: true);
  List<dynamic> filteredTransactions = List.empty(growable: true);

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
    assetProvider.assets.clear();
    Asset waves = await fetchAssetInfo("WAVES");
    assetsGlobal[waves.id] = waves;
    progressProvider.start();
    await getTransactions(address: curAddr);
    await getAssets(curAddr);
    await getNft(address: address);
    // await getNft(curAddr); //implement
    await getData(curAddr); //implement
    await getScript(curAddr); //implement
    progressProvider.stop();
    notifyListeners();
  }

  Future<void> getMoreTransactions() async{
    await getTransactions(address: curAddr, after: true);
  }

  Future<void> getTransactions({required String address, bool? after}) async {
    if (curAddr.isNotEmpty) {
      progressProvider.startTransactions();
      final filterProvider = FilterProvider();
      bool stopDate = false;
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
          // print("Loaded: " + res.length.toString());
          if(res.isEmpty) {
            stopDate = true;
            print("--- TransactionProvider getTransactions() empty transactions list got");
          } else {
            var lastTrans = res[res.length - 1];
            afterGlob = lastTrans["id"];
            final curFromDateTs = dateToTimestamp(filterProvider.from);
            stopDate = lastTrans["timestamp"] < curFromDateTs || curFromDateTs == 0;
            // print("LastTrans: $afterGlob, trts: ${lastTrans["timestamp"]}, curFromDateTs: $curFromDateTs");
          }

        } else {
          progressProvider.stopTransactions();
          throw("Failed to load transactions list\n" + resp.body);
        }
      
        if (after == "") {
          allTransactions = res;
        } else {
          allTransactions.addAll(res);
        }
        final ids = await extractAssets(res);
        await getMassAssetsInfo(ids);
        fillTransactionsWithAssetsNames(res);

        filteredTransactions = allTransactions;
        final lastTrans = allTransactions.isEmpty ? null : allTransactions[allTransactions.length-1];
        final firstTrans = allTransactions.isEmpty ? null : allTransactions[0];
        filterProvider.actualFrom = lastTrans == null ? DateTime.now() : timestampToDate(lastTrans["timestamp"]);
        filterProvider.actualTo = firstTrans == null ? DateTime.now() : timestampToDate(firstTrans["timestamp"]);
        filterTransactions();
      }

      progressProvider.stopTransactions();

      // print("Loaded ${allTransactions.length}, last: $afterGlob");
      // JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      // for (var value in allTransactions) {
      //   print(encoder.convert(value));
      // }
      // allTransactions = allTransactions.where((element) => element["type"] == 16).toList();
    }
  }

  Future<dynamic> getWavesBalances() async {
    dynamic res;
    var resp = await http.get(Uri.parse("$nodeUrl/addresses/balance/details/$curAddr"));
    if (resp.statusCode == 200) {
      res = jsonDecode(resp.body);
    } else {
      throw("Error while loading waves balances");
    }
    return res;
  }

  // Loop through transactions and find all assets ids and addresses present in transaction
  // create sets in each transaction json and global set(for next step - fetching names)
  Future<Map<String, String>> extractAssets(List<dynamic> transactions) async {
    final assetsLocalIds = <String, String>{};
    for (var tr in transactions) {
      final transAssetsMap = <String, String>{};
      final trAddressesMap = <String, String>{};
      final Map<String, double> inAssetsIds = {};
      final Map<String, double> outAssetsIds = {};
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

        if(type == 6) {
          outAssetsIds[assetId] = tr["amount"];
        }
        if(type == 4) {
          curAddr == tr["sender"] ? outAssetsIds[assetId] == tr["amount"] : inAssetsIds[assetId] = tr["amount"];
        }
        if(type == 11) {
          bool income = true;
          double sum = 0;
          final transfers = tr["transfers"];
          for (var el in transfers) {
            if(curAddr == tr["sender"]) {
              income = false;
              sum += el["amount"];
            } else {
              if(el["recipient"] == curAddr) {
                sum += el["amount"];
              }
            }
          }
          income ? inAssetsIds[assetId] = sum : outAssetsIds[assetId] = sum;
        }

      }

      // invokeScript
      if (type == 16) {
        List<dynamic> payment = tr["payment"];
        for (var pay in payment) {
          String assetId = pay["assetId"] ?? "WAVES";
          transAssetsMap[assetId] = assetId == "WAVES" ? "WAVES" : "";
          if(curAddr == tr["dApp"]) {
            inAssetsIds[assetId] = pay["amount"];
          } else {
            outAssetsIds[assetId] = pay["amount"];
          }
        }
      }

      //invokeScript
      if (type == 16) {
        final isDapp = tr["dApp"] == curAddr;
        List<dynamic> transfers = tr["stateChanges"]["transfers"];
        for (var pay in transfers) {
          if (isDapp && (pay["address"] == tr["sender"]) || (!isDapp && pay["address"] == curAddr)) {
            String asset = pay["asset"] ?? "WAVES";
            transAssetsMap[asset] = asset == "WAVES" ? "WAVES" : "";
            trAddressesMap[pay["address"]] = getAddrName(pay["address"]);
            if(curAddr == tr["dApp"]) {
              outAssetsIds[asset] = pay["amount"];
            } else {
              inAssetsIds[asset] = pay["amount"];
            }
          }
        }
      }

      // exchange
      if (type == 7) {
        final p = parseTransactionType(tr);
        final assId = p["amountAsset"];
        final prassId = p["priceAsset"];
        transAssetsMap[assId] = "";
        transAssetsMap[prassId] = "";
        final seller = p["seller"];
        final buyer = p["buyer"];
        trAddressesMap[seller] = getAddrName(seller);
        trAddressesMap[buyer] = getAddrName(buyer);
          outAssetsIds.addAll(p["payment"]);
          inAssetsIds.addAll(p["transfers"]);
      }

      tr["addresses"] = trAddressesMap;
      tr["assetsIds"] = transAssetsMap;
      tr["addressesNames"] = trAddressesMap.values.join(",");

      tr["inAssetsIds"] = inAssetsIds;
      tr["outAssetsIds"] = outAssetsIds;
      assetsLocalIds.addAll(transAssetsMap);
    }
    return assetsLocalIds;
  }

  Future<void> getAssets(String address) async {
    progressProvider.startAssets();
    var tmpass = <String, dynamic> {};
    var res = <dynamic>[];
    var resp = await http.get(Uri.parse("$nodeUrl/assets/balance/$address"));
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      res = json["balances"];
      for (dynamic el in res) {
        tmpass[el["assetId"]] = el;
      }
    } else {
      progressProvider.stopAssets();
      throw("Failed to load assets list. \n" + resp.body);
    }

    await getMassAssetsInfo(tmpass);
    dynamic wavesBalances = await getWavesBalances();
    AccAsset wavesAsset = AccAsset(assetsGlobal["WAVES"], wavesBalances["available"], 3, "");
    wavesAsset.staked = wavesBalances["regular"] - wavesBalances["available"];
    assetProvider.assets.add(wavesAsset);
    tmpass.forEach((key, value) {
      int priority = 0;
      if(priorityThree.contains(assetsGlobal[key]!.name)) {
        priority = 3;
      }
      if(priorityTwo.contains(assetsGlobal[key]!.name)) {
        priority = 2;
      }
      if(priorityOne.contains(assetsGlobal[key]!.name)) {
        priority = 1;
      }
      assetProvider.assets.add(AccAsset(assetsGlobal[key], value["balance"], priority, value));
    });
    assetProvider.sortAssets();
    assetProvider.filterAssets();
    progressProvider.stopAssets();
  }

  Future<void> getMoreNfts() async{
    await getNft(address: curAddr, after: true);
  }

  Future<void> getNft({required String address, bool? after}) async {
    List<dynamic> res = List.empty(growable: true);
    if(curAddr.isNotEmpty) {
      progressProvider.startNfts();
      String afterId = after == null ? "" : afterGlobNft;
      var resp = await http.get(Uri.parse("$nodeUrl/assets/nft/$address/limit/$limitNft?after=$afterId"));
      if(resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        res = json;
      } else {
        progressProvider.stopNfts();
        throw("Cant fetch NFTs list: " + resp.body);
      }
      if(afterId.isEmpty) {
        nftProvider.nfts = res;
      } else {
        nftProvider.nfts.addAll(res);
      }
      // print("Loaded Nfts: " + nftProvider.nfts.length.toString());
      nftProvider.filterNfts();
      progressProvider.stopNfts();
    }
  }

  Future<void> getData(String address) async{
    progressProvider.startData();
    List<dynamic> res = List.empty(growable: true);
    var resp = await http.get(Uri.parse("$nodeUrl/addresses/data/$curAddr"));
    if(resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      // print(json);
      res = json;
    } else {
      progressProvider.stopData();
      throw("Cant fetch data from account data storage :" + resp.body);
    }
    dataScriptProvider.data = res;
    dataScriptProvider.filterData();
    progressProvider.stopData();
  }

  Future<void> getScript(String address) async{
    if (curAddr.isNotEmpty) {
      dataScriptProvider.script = "";
      progressProvider.startScript();
      var resp = await http.get(Uri.parse("$nodeUrl/addresses/scriptInfo/$curAddr"));
      if(resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        var scrpt = json["script"];
        if (scrpt != null) {
          String ftf = scrpt.toString().substring(7);
          var decoded = await http.post(Uri.parse("$nodeUrl/utils/script/decompile"), body: ftf);
          if(decoded.statusCode == 200) {
            final jsn = jsonDecode(decoded.body);
            dataScriptProvider.script = jsn["script"];
          } else {
            progressProvider.stopScript();
            throw("Cant fetch decompiled script: " + decoded.body);
          }
        }
      } else {
        progressProvider.stopScript();
        throw("Cant load account script: " + resp.body);
      }
      dataScriptProvider.notifyListeners();
      progressProvider.stopScript();
    }
  }

  void fillTransactionsWithAssetsNames(List<dynamic> res) {
    for (var tr in res) {
      // print(tr);
      Map<String, String> assets = tr["assetsIds"];
      for (String e in assets.keys) {
        assets[e] = assetsGlobal.containsKey(e) ? assetsGlobal[e]!.name : "";
      }
      tr["assetsNames"] = assets.values.join(",");

      //create in/out assets names strings
      final List<String> inNames = List.empty(growable: true);
      final List<String> outNames = List.empty(growable: true);
      for(String el in tr["inAssetsIds"].keys) {
        inNames.add(assetsGlobal.containsKey(el) ? assetsGlobal[el]!.name : "");
      }
      for(String el in tr["outAssetsIds"].keys) {
        outNames.add(assetsGlobal.containsKey(el) ? assetsGlobal[el]!.name : "");
      }
      tr["inAssetsNames"] = inNames.join(",");
      tr["outAssetsNames"] = outNames.join(",");

      //correcting decimals for price asset for exchange transactions
      if(tr["type"] == 7) {
        final priceAsset = tr["order1"]["assetPair"]["priceAsset"] ?? "WAVES";
        final amountAsset = tr["order1"]["assetPair"]["amountAsset"] ?? "WAVES";
        final amountDecimals = assetsGlobal[amountAsset]!.decimals;
        if(tr["inAssetsIds"].containsKey(priceAsset)) {
          tr["inAssetsIds"][priceAsset] = tr["inAssetsIds"][priceAsset]/pow(10, amountDecimals);
        }
        if(tr["outAssetsIds"].containsKey(priceAsset)) {
          tr["outAssetsIds"][priceAsset] = tr["outAssetsIds"][priceAsset]/pow(10, amountDecimals);
        }
      }
    }
  }

  void filterTransactions() {
    final filterProvider = FilterProvider();
    List<dynamic> datedTransactions = List.from(allTransactions);
    // print("Transactions loaded: " + datedTransactions.length.toString());
    if (filterProvider.to != null) {
      int toTS = dateToTimestamp(filterProvider.to!);
      datedTransactions = datedTransactions.where((tr) => tr["timestamp"] < toTS).toList();
    }
    // print("Transactions to: " + datedTransactions.length.toString());
    if (filterProvider.from != null) {
      int fromTS = dateToTimestamp(filterProvider.from!);
      datedTransactions = datedTransactions.where((tr) => tr["timestamp"] >= fromTS).toList();
    }
    // print("Transactions from: " + datedTransactions.length.toString());
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

    print("Filtering direction: ${filterProvider.direction}");
    if(filterProvider.direction == "all") {
      filteredTransactions = trToFilter.where((tr) => tr["assetsNames"].toLowerCase().contains(filterProvider.assetName.toLowerCase())).toList();
    }
    if(filterProvider.direction == "in") {
      filteredTransactions = trToFilter.where((tr) => tr["inAssetsNames"].toLowerCase().contains(filterProvider.assetName.toLowerCase())).toList();
    }
    if(filterProvider.direction == "out") {
      filteredTransactions = trToFilter.where((tr) => tr["outAssetsNames"].toLowerCase().contains(filterProvider.assetName.toLowerCase())).toList();
    }

    createInfo();
    notifyListeners();
  }
}



