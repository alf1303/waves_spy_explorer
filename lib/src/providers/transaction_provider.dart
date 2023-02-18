import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/nft.dart';
import 'package:waves_spy/src/providers/asset_provider.dart';
import 'package:waves_spy/src/providers/data_script_provider.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/nft_provider.dart';
import 'package:waves_spy/src/providers/progress_bars_provider.dart';
import 'package:waves_spy/src/providers/stats_provider.dart';
import 'package:fast_base58/fast_base58.dart';

import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

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
  final statsProvider = StatsProvider();
  DateTime lastLoadedTransactionDate = DateTime.now();
  String curAddr = "";
  List<String> aliases = List.empty(growable: true);
  String afterGlob = "";
  String afterGlobNft = "";
  int limit = 1000;
  int limitNft = 1000;

  bool isLoading = false;
  bool stakedDucksLoaded = false;
  bool jediDucksLoaded = false;
  bool allTransactionsLoaded = false;

  Widget filterData = Text("Filter options: ", style: TextStyle(fontSize: getLastFontSize()),);

  List<dynamic> allTransactions = List.empty(growable: true);
  List<dynamic> filteredTransactions = List.empty(growable: true);

  List<dynamic> data = List.empty(growable: true);
  String script = "";
  dynamic wavesBalance = {
    "regular": 0,
    "generating": 0,
    "available": 0,
    "effective": 0};

  Future<List<String>> fetchAliases(String addr) async{
    List<dynamic> result = List.empty(growable: false);
    var resp = await http.get(Uri.parse("$nodeUrl/alias/by-address/$addr"));
    if(resp.statusCode == 200) {
      result = jsonDecode(resp.body);
    } else {
      print("Cant fetch aliases by address: ${resp.body}");
    }
    return result.map((e) => e.toString()).toList();
  }

  void createInfo() {
    final _filterProvider = FilterProvider();
    filterData = _filterProvider.createFilterDataString(allTransactions.length, filteredTransactions.length, getLastFontSize());
  }

  Future<void> setCurrAddr(String address) async {
    if(dAppsDict.isEmpty) {
      dAppsDict.addAll(publicAddr);
    }
    curAddr = address;
    setLabelAddr();
    final aliasReg =  RegExp(r'^[a-z0-9._\-@]+$');
    if(address.isNotEmpty && aliasReg.hasMatch(address)) {
      String adr = await fetchAddrByAlias("alias:W:" + address);
      curAddr = adr;
    }
    clearStateBeforeNewSearch();
    Asset waves = await fetchAssetInfo("WAVES");
    assetsGlobal[waves.id] = waves;
    progressProvider.start();
    aliases = await fetchAliases(curAddr);
    // print("Aliases: ");
    // print(aliases);
    print("** Start loading transactions");
    // bool result = await getTransactions(address: curAddr);
    if (true) { // (result) {
      await getAssets(curAddr);
      print("** Assets loaded");
      await getTransactions(address: curAddr);
      print("** Transactions loaded");
      await getData(curAddr); //implement
      print("** Data loaded");
      await getScript(curAddr); //implement
      print("** Script loaded");
      await getNft(address: curAddr);
      print("** Nft loaded");
      setDucksStatsData();
    }
    statsProvider.notifyAll();
    progressProvider.stop();
    isLoading = false;
    notifyListeners();
  }

  clearStateBeforeNewSearch() {
      //transactions
    afterGlob = "";
    allTransactions.clear();
    aliases.clear();
    stakedDucksLoaded  = false;
    jediDucksLoaded = false;
    allTransactionsLoaded = false;

      //filter
    final filterProvider = FilterProvider();
    filterProvider.finalList.clear();

      //other
    assetProvider.assets.clear();
    nftProvider.nfts.clear();
    dataScriptProvider.data.clear();
    dataScriptProvider.script = "";

    //stats
    statsProvider.clearState();
  }

  Future<void> getAllTransactions() async{
    final filterProvider = FilterProvider();
    filterProvider.from = DateTime(2017);
    await getTransactions(address: curAddr, after: true);
  }

  Future<void> getMoreTransactions() async{
    await getTransactions(address: curAddr, after: true);
  }

  Future<bool> getTransactions({required String address, bool? after, BuildContext? context}) async {
    if (curAddr.isNotEmpty) {
      progressProvider.startTransactions();
      final filterProvider = FilterProvider();
      bool stopDate = false;
      List<dynamic> res = List.empty(growable: true);
      while (!stopDate) {
        String afterId = after == null ? "" : afterGlob;
        after = true;
        var resp;
        int attempts = 10;
        while (attempts > 0) {
          try {
            resp = await http.get(Uri.parse("$nodeUrl/transactions/address/$address/limit/$limit?after=$afterId"));
            attempts = 0;
          } catch(err) {
            attempts -= 1;
            print("Catched XMLHttpRequest error, retrying... $attempts left");
          }
        }
        // print("trx");
        // print(resp.body);
        // print("");
        if (resp.statusCode == 200) {
          final json = jsonDecode(resp.body);
          res = json[0];
          print("Loaded: " + res.length.toString());
          if(res.isEmpty) {
            stopDate = true;
            allTransactionsLoaded = true;
            print("--- TransactionProvider getTransactions() empty transactions list got");
          } else {
            var lastTrans = res[res.length - 1];
            afterGlob = lastTrans["id"];
            final curFromDateTs = dateToTimestamp(filterProvider.from);
            stopDate = lastTrans["timestamp"] < curFromDateTs || curFromDateTs == 0;
            print("LastTrans: $afterGlob, trts: ${lastTrans["timestamp"]}, curFromDateTs: $curFromDateTs");
          }

        } else {
          progressProvider.stopTransactions();
          progressProvider.stop();
          showSnackError(resp.body);
          print("Failed to load transactions list\n" + resp.body);
          // throw("Transactions not loaded");
          progressProvider.notify();
          return false;
        }
      
        if (after == "") {
          filterProvider.reverseTransactions ? allTransactions = res.reversed.toList() : allTransactions = res;
        } else {
          filterProvider.reverseTransactions ? allTransactions.insertAll(0, res.reversed) : allTransactions.addAll(res);
        }
        // print("zuzu");
        final ids = await extractAssets(res);
        await getMassAssetsInfo(ids);
        fillTransactionsWithAssetsNames(res);
        filteredTransactions = allTransactions;

        print("loading filter start");
        filterTransactions();
        print("loading filter finish");

        // createInfo();
        filterProvider.notifyAll();
        statsProvider.notifyAll();
        progressProvider.notify();
      }
      dynamic lastTrLoaded = filterProvider.reverseTransactions ? allTransactions[0] : allTransactions[allTransactions.length - 1];
      lastLoadedTransactionDate = timestampToDate(lastTrLoaded["timestamp"]);
      progressProvider.stopTransactions();

      // print("Loaded ${allTransactions.length}, last: $afterGlob");
      // JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      // for (var value in allTransactions) {
      //   print(encoder.convert(value));
      // }
      // allTransactions = allTransactions.where((element) => element["type"] == 16).toList();
    }
    return true;
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
    // print("ex_1");
    final assetsLocalIds = <String, String>{};
    for (var tr in transactions) {
      // print(tr["id"]);
      final bool fail = tr["applicationStatus"] == "script_execution_failed";
      tr["additional"] = <String, dynamic>{};
      tr["additional"]["tradeAddrCount"] = 0;
      if (tr.containsKey("attachment") && tr["attachment"].length > 0) {
        var raw;
        try {
          raw = Base58Decode(tr["attachment"]);
          tr["attachment"] = utf8.decode(raw);
        } catch(err) {
          print("Attachement decode error, ${tr["attachment"]}, " + err.toString());
        }
      }
      final transAssetsMap = <String, String>{};
      final trAddressesMap = <String, String>{};
      final Map<String, double> inAssetsIds = {};
      final Map<String, double> outAssetsIds = {};
      int type = tr["type"];
      tr.containsKey("sender") ? trAddressesMap[tr["sender"]] = getAddrName(tr['sender']) : {};
      tr.containsKey("dApp") ? trAddressesMap[tr["dApp"]] = getAddrName(tr["dApp"]) : {};

      // transfer, massTransfer, burn
      if (type == 4 || type == 11 || type == 6) {
        String assetId = tr["assetId"] ?? "WAVES";
        transAssetsMap[assetId] = assetId == "WAVES" ? "WAVES" : "";

        if(type == 6) {
          outAssetsIds[assetId] = tr["amount"];
        }
        if(type == 4) {
          trAddressesMap[tr["recipient"]] = getAddrName(tr["recipient"]);
          // curAddr == tr["sender"] ? outAssetsIds[assetId] == tr["amount"] : inAssetsIds[assetId] = tr["amount"];
          if(isCurrentAddr(tr["sender"])) {
            outAssetsIds[assetId] = tr["amount"];
          } else {
            inAssetsIds[assetId] = tr["amount"];
          }
        }
        if(type == 11) {
          bool income = true;
          double sum = 0;
          final transfers = tr["transfers"];
          for (var el in transfers) {
            income = true;
            trAddressesMap[el["recipient"]] = getAddrName(el["recipient"]);
            if(isCurrentAddr(tr["sender"])) {
              income = false;
              sum += el["amount"];
            } else {
              if(isCurrentAddr(el["recipient"])) {
                sum += el["amount"];
              }
            }
          }
          income ? inAssetsIds[assetId] = sum : outAssetsIds[assetId] = sum;
        }
      }

      // issue / reissue
      if(type == 3 || type == 5) {
        final String assetId = tr["assetId"] ?? "WAVES";
        final double quantity = tr["quantity"];
        transAssetsMap[assetId] = assetId == "WAVES" ? "WAVES" : "";
        inAssetsIds[assetId] = quantity;
      }

      // invokeScript
      if (type == 16) {
        List<dynamic> payment = tr["payment"];
        for (var pay in payment) {
          String assetId = pay["assetId"] ?? "WAVES";
          transAssetsMap[assetId] = assetId == "WAVES" ? "WAVES" : "";
          if(isCurrentAddr(tr["dApp"])) {
            inAssetsIds[assetId] = pay["amount"];
          } else {
            if (isCurrentAddr(tr["sender"])) {
              outAssetsIds[assetId] = pay["amount"];
            }
          }
        }
        statsProvider.addCall(tr["call"]["function"]);
      }

      //invokeScript
      if (type == 16) {
        final isDapp = isCurrentAddr(tr["dApp"]);
        List<dynamic> transfers = tr["stateChanges"]["transfers"];
        for (var pay in transfers) {
          if (isDapp && (pay["address"] == tr["sender"]) || (!isDapp && isCurrentAddr(pay["address"]))) {
            String asset = pay["asset"] ?? "WAVES";
            transAssetsMap[asset] = asset == "WAVES" ? "WAVES" : "";
            trAddressesMap[pay["address"]] = getAddrName(pay["address"]);
            if(isCurrentAddr(tr["dApp"])) {
              outAssetsIds[asset] = pay["amount"];
            } else {
              inAssetsIds[asset] = pay["amount"];
            }
          }
        }
        collectDucksStats(tr);
        tr["additional"]["tradeAddrCount"] = collectTradeAccsData(tr);
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

      tr["additional"]["fail"] = fail;
      tr["additional"]["addresses"] = trAddressesMap;
      tr["additional"]["assetsIds"] = transAssetsMap;
      tr["additional"]["addressesNames"] = trAddressesMap.values.join(",");
      tr["additional"]["addressesIds"] = trAddressesMap.keys.join(",");

      tr["additional"]["inAssetsIds"] = fail ? {} : inAssetsIds;
      tr["additional"]["outAssetsIds"] = fail ? {} : outAssetsIds;
      assetsLocalIds.addAll(transAssetsMap);
    }
    // print("ouyeh");
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
      // print("$key : ${assetsGlobal.containsKey(key)}");
      int priority = 0;
      if(assetsGlobal.containsKey(key)) {
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
      } else {
        print("Assets id $key is not preset in assetsGlobal");
        showSnackError("Assets id $key is not preset in assetsGlobal");
        // throw("Assets id $key is not preset in assetsGlobal");
      }
    });
    // print("3");
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
      bool stop = false;
      while (!stop) {
        String afterId = after == null ? "" : afterGlobNft;
        var resp = await http.get(Uri.parse("$nodeUrl/assets/nft/$address/limit/$limitNft?after=$afterId"));
        if(resp.statusCode == 200) {
          final json = jsonDecode(resp.body);
          res = json;
          if(res.isEmpty) {
            stop = true;
          } else {
            var lastNft = res[res.length - 1];
            after = true;
            afterGlobNft = lastNft["assetId"];
            print(afterGlobNft);
            // print("LastTrans: $afterGlob, trts: ${lastTrans["timestamp"]}, curFromDateTs: $curFromDateTs");
          }
        } else {
          progressProvider.stopNfts();
          print("Cant fetch NFTs list: " + resp.body);
          showSnackError("Cant fetch NFTs list: " + resp.body);
          // throw("Cant fetch NFTs list: " + resp.body);
        }
        List<Nft> nftList = res.map((e) => Nft(
            data: e,
            isDuck: e["name"].contains("DUCK") && (e["issuer"] == "3PEktVux2RhchSN63DsDo4b4mz4QqzKSeDv" || e["issuer"] == "3PDVuU45H7Eh5dmtNbnRNRStGwULA7NY6Hb" || e["issuer"] == "3PKmLiGEfqLWMC1H9xhzqvAZKUXfFm8uoeg"),
            isFarming: false,
            farmingPower: 0
        )).toList();
        if(afterId.isEmpty) {
          nftProvider.nfts = nftList;
        } else {
          nftProvider.nfts.addAll(nftList);
        }
      }
      // print("Loaded Nfts: " + nftProvider.nfts.length.toString());
      if(!stakedDucksLoaded) {
        Map<String, int> stakedDucks = await getStakedDucks(address);
        List<dynamic> stakedDucksData = await getMassAssets(stakedDucks);
        List<Nft> stakedDucksNft = stakedDucksData.map((el) =>
            Nft(
                data: el,
                isDuck: true,
                isFarming: true,
                farmingPower: stakedDucks[el["assetId"]] ?? 0
            )).toList();
        stakedDucksLoaded = true;
        nftProvider.nfts.addAll(stakedDucksNft);

      }
      if(!jediDucksLoaded) {
        Map<String, JediItem> jediDucks = await getJediDucks(address);
        List<dynamic> jediDucksData = await getMassAssets(jediDucks);
        List<Nft> jediDucksNfts = jediDucksData.map((el) => Nft.jedi(
          data: el,
          isDuck: true,
          isDjedi: true,
          mantleLvl: jediDucks[el["assetId"]]!.mantlelvl
        )).toList();
        jediDucksLoaded = true;
        nftProvider.nfts.addAll(jediDucksNfts);
      }
      
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
      print("Cant fetch data from account data storage :" + resp.body);
      showSnackError("Cant fetch data from account data storage :" + resp.body);
      // throw("Cant fetch data from account data storage :" + resp.body);
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
      Map<String, String> assets = tr["additional"]["assetsIds"];
      for (String e in assets.keys) {
        assets[e] = assetsGlobal.containsKey(e) ? assetsGlobal[e]!.name : "";
      }
      tr["additional"]["assetsNames"] = assets.values.toList();

      //create in/out assets names strings
      final List<String> inNames = List.empty(growable: true);
      final List<String> outNames = List.empty(growable: true);
      for(String el in tr["additional"]["inAssetsIds"].keys) {
        inNames.add(assetsGlobal.containsKey(el) ? assetsGlobal[el]!.name : "");
      }
      for(String el in tr["additional"]["outAssetsIds"].keys) {
        outNames.add(assetsGlobal.containsKey(el) ? assetsGlobal[el]!.name : "");
      }
      tr["additional"]["inAssetsNames"] = inNames;
      tr["additional"]["outAssetsNames"] = outNames;

      //correcting decimals for price asset for exchange transactions
      if(tr["type"] == 7) {
        final priceAsset = tr["order1"]["assetPair"]["priceAsset"] ?? "WAVES";
        final amountAsset = tr["order1"]["assetPair"]["amountAsset"] ?? "WAVES";
        final amountDecimals = assetsGlobal[amountAsset]!.decimals;
        if(tr["additional"]["inAssetsIds"].containsKey(priceAsset)) {
          tr["additional"]["inAssetsIds"][priceAsset] = tr["additional"]["inAssetsIds"][priceAsset]/pow(10, amountDecimals);
        }
        if(tr["additional"]["outAssetsIds"].containsKey(priceAsset)) {
          tr["additional"]["outAssetsIds"][priceAsset] = tr["additional"]["outAssetsIds"][priceAsset]/pow(10, amountDecimals);
        }
      }
    }
  }

  void filterTransactions() {
    print("filter1");
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
    if (filterProvider.fType.isNotEmpty) {
      filteredTransactions = datedTransactions
          .where((tr) => filterProvider.fType.contains(tr["type"]))
          .toList();
    } else {
      filteredTransactions = datedTransactions;
    }
    print("filter2");
    if(filterProvider.addrName.isNotEmpty) {
      filteredTransactions = filteredTransactions.where((tr) => tr["additional"]["addressesIds"].toLowerCase().contains(filterProvider.addrName.toLowerCase())).toList();
    }

    if(filterProvider.fType.contains(16) && filterProvider.functName.isNotEmpty) {
      List<dynamic> invokeTrs = filteredTransactions.where((tr) => tr["type"] == 16).toList();
      filteredTransactions.removeWhere((tr) => tr["type"] == 16);
      invokeTrs = invokeTrs.where((tr) => tr["call"]["function"].toLowerCase().contains(filterProvider.functName.toLowerCase())).toList();
      filteredTransactions.addAll(invokeTrs);
    }

    if(filterProvider.onlyTraders) {
      filteredTransactions = filteredTransactions.where((tr) => tr["additional"] != null && tr["additional"]["tradeAddrCount"] != null && tr["additional"]["tradeAddrCount"] >= 1).toList();
    }

    if(filterProvider.hideFailed) {
      filteredTransactions = filteredTransactions.where((tr) => tr["additional"] != null && tr["additional"]["fail"] != null && !tr["additional"]["fail"]).toList();
    }

    final trToFilter = filterProvider.isFiltered() ? filteredTransactions : datedTransactions;
    double minval = double.parse(filterProvider.minValue);
    if(minval > 0) {
      List<dynamic> res = List.empty(growable: true);
      for(var tr in trToFilter) {
        bool inHaveBigger = false;
        bool outHaveBigger = false;
        for(var p in tr["additional"]["inAssetsIds"].keys) {
          inHaveBigger = tr["additional"]["inAssetsIds"][p]/pow(10, assetsGlobal[p]!.decimals) > minval;
        }
        for(var p in tr["additional"]["outAssetsIds"].keys) {
          outHaveBigger = tr["additional"]["outAssetsIds"][p]/pow(10, assetsGlobal[p]!.decimals) > minval;
        }
        if (inHaveBigger || outHaveBigger) {
          res.add(tr);
        }
      }
      trToFilter.clear();
      trToFilter.addAll(res);
    }

    // if(filterProvider.direction == "all") {
    //   filteredTransactions = trToFilter.where((tr) => tr["additional"]["assetsNames"].toLowerCase().contains(filterProvider.assetName.name.toLowerCase())).toList();
    // }
    // if(filterProvider.direction == "in") {
    //   filteredTransactions = trToFilter.where((tr) => tr["additional"]["inAssetsNames"].toLowerCase().contains(filterProvider.assetName.name.toLowerCase())).toList();
    // }
    // if(filterProvider.direction == "out") {
    //   filteredTransactions = trToFilter.where((tr) => tr["additional"]["outAssetsNames"].toLowerCase().contains(filterProvider.assetName.name.toLowerCase())).toList();
    // }
    print("filter 2.5");
    if (filterProvider.assetName.name.isNotEmpty) {
      if(filterProvider.direction == "all") {
        filteredTransactions = trToFilter.where((tr) => isInListOfStrings(tr["additional"]["assetsIds"].keys.toList(), filterProvider.assetName.id)).toList();
      }
      if(filterProvider.direction == "in") {
        filteredTransactions = trToFilter.where((tr) => isInListOfStrings(tr["additional"]["inAssetsIds"].keys.toList(), filterProvider.assetName.id)).toList();
      }
      if(filterProvider.direction == "out") {
        filteredTransactions = trToFilter.where((tr) => isInListOfStrings(tr["additional"]["outAssetsIds"].keys.toList(), filterProvider.assetName.id)).toList();
      }
    }
    filteredTransactions = filteredTransactions.toSet().toList();
    final lastTrans = filteredTransactions.isEmpty ? null : filteredTransactions[filteredTransactions.length-1];
    final firstTrans = filteredTransactions.isEmpty ? null : filteredTransactions[0];
    filterProvider.actualFrom = lastTrans == null ? DateTime.now() : timestampToDate(lastTrans["timestamp"]);
    filterProvider.actualTo = firstTrans == null ? DateTime.now() : timestampToDate(firstTrans["timestamp"]);
    createInfo();
    notifyListeners();
    print("filter3");
  }

  Future<Map<String, int>> getStakedDucks(String address) async{
    List<dynamic> res = List.empty(growable: true);
    String farmingAddress = "3PAETTtuW7aSiyKtn9GuML3RgtV1xdq1mQW";
    var resp = await http.get(Uri.parse("$nodeUrl/addresses/data/$farmingAddress"));
    if(resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      // print(json);
      res = json;
    } else {
      throw("Cant fetch data from account data storage for staked ducks:" + resp.body);
    }
    // print("staked ducks length: ${res.length}");
    final List<dynamic> filtered = res.where((ele) => ele["key"].contains(address) && ele["key"].contains("_farmingPower") && ele["value"] > 0).toList();
    final Map<String, int> ress = { for (var e in filtered) e["key"].split("_")[3] : e["value"] };
    return ress;
  }

  Future<Map<String, JediItem>> getJediDucks(String address) async{
    List<dynamic> res = List.empty(growable: true);
    String gameAddress = "3PR87TwfWio6HVUScSaHGMnFYkGyaVdFeqT";
    var resp = await http.get(Uri.parse("$nodeUrl/addresses/data/$gameAddress"));
    if(resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      // print(json);
      res = json;
    } else {
      throw("Cant fetch data from account data storage for staked ducks:" + resp.body);
    }
    // print("staked ducks length: ${res.length}");
    final List<dynamic> filtered = res.where((ele) => ele["key"].contains(address) && ele["key"].contains("_artefact_mantle_artefactId_") && ele["key"].contains("_duck_")  && ele["key"].contains("status") && ele["value"]).toList();
    final List<dynamic> mantles = res.where((ele) => ele["key"].contains(address) && ele["key"].contains("level")).toList();
    final Map<String, int> mantlelevels = {for (var el in mantles) el["key"].split("_")[5]: el["value"]};
    final Map<String, JediItem> ress = { for (var e in filtered) e["key"].split("_")[3] : JediItem(e["key"].split("_")[1], e["key"].split("_")[3], e["key"].split("_")[7], mantlelevels[e["key"].split("_")[7]]!) };
    return ress;
  }

  bool isInListOfStrings(List<dynamic> list, String item) {
    for (String el in list) {
      if (el == item) {
        return true;
      }
    }
    return false;
  }

  int collectTradeAccsData(tr) {
    int count = 0;
    if(tr.containsKey("stateChanges")) {
      final trsf = tr["stateChanges"]["transfers"];
      for(var el in trsf) {
        if (traders.contains(el["address"])) {
          count ++;
        }
      }
    }
    return count;
  }
}

class JediItem {
  String address;
  String duck;
  String mantleId;
  int mantlelvl;

  JediItem(this.address, this.duck, this.mantleId, this.mantlelvl);
}



