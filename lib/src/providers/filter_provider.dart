import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/addresses_stats_item.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/styles.dart';
import 'package:waves_spy/src/widgets/other/custom_widgets.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

import '../models/asset.dart';

class FilterProvider extends ChangeNotifier{
  static final FilterProvider _instance = FilterProvider._internal();
  factory FilterProvider() {
    return _instance;
  }
  FilterProvider._internal();
  final _transactionProvider = TransactionProvider();
  DateTime? actualFrom;
  DateTime? actualTo;
  DateTime? from;
  DateTime? to;
  List<int> fType = [];
  String functName = "";
  String addrName = "";
  Asset assetName = Asset.empty();
  String direction = "all";
  bool reverseTransactions = false;
  bool onlyTraders = false; // addresses, created for trading activity
  String minValue = "0";
  bool highlightTradeAccs = false;

  Map<String, AddressesStatsItem> finalList = {};
  double sumacum_in = 0;
  double sumacum_out = 0;

  //create RichText for indicating current filter parameters
  Widget createFilterDataString(int allTrxLength, int filteredTrxLength) {
    final types = fType.map((e) => typeDict[e]).join(", ");
    String sum_in = "";
    String sum_out = "";

    String type = fType.isEmpty ? "" : types;
    String functionName = functName.isEmpty ? "" : functName;
    String assetNameStr = assetName.name;
    String fromDate = actualFrom == null ? "" : getFormattedDate(actualFrom);
    String toDate = actualTo == null ? "" : getFormattedDate(actualTo);

    //Calculating income/outcome summs
    finalList.clear();
    if(assetName.name.isNotEmpty) {
      sumacum_in = 0;
      sumacum_out = 0;
      String assId = assetName.id;
      print("CreateFilterDAtaStrings decimals: ${assetName.decimals}");
      for (var tr in _transactionProvider.filteredTransactions) {
        var additional = tr["additional"];
        int type = tr["type"];
        // print(additional);
        // print(assId);
        if(tr["additional"]["inAssetsIds"].containsKey(assetName.id)) {
          // assId = tr["additional"]["inAssetsIds"].keys.toList()[0];
          int decimals = assetName.decimals;
          double val = tr["additional"]["inAssetsIds"][assId]/pow(10, decimals);
          sumacum_in += tr["additional"]["inAssetsIds"][assId]/pow(10, decimals);
          if(type == 16 && isCurrentAddr(tr["dApp"])) {
            addNewEntryOrCombine(finalList, val, tr["sender"], "in", additional["tradeAddrCount"]);
          } else if(type == 16) {
            addNewEntryOrCombine(finalList, val, tr["dApp"], "in", additional["tradeAddrCount"]);
          } else {
            addNewEntryOrCombine(finalList, val, tr["sender"], "in", additional["tradeAddrCount"]);
          }
        }

        if(tr["additional"]["outAssetsIds"].containsKey(assetName.id)) {
          // assId = tr["additional"]["outAssetsIds"].keys.toList()[0];
          int decimals = assetsGlobal[assId] == null ? 1 : assetsGlobal[assId]!.decimals;
          double val = tr["additional"]["outAssetsIds"][assId]/pow(10, decimals);
          sumacum_out += val;
          if (type == 16 && isCurrentAddr(tr["dApp"])) {
            addNewEntryOrCombine(finalList, val, tr["sender"], "out", additional["tradeAddrCount"]);
          } else if(type == 16) {
            addNewEntryOrCombine(finalList, val, tr["dApp"], "out", additional["tradeAddrCount"]);
          } else if(type == 4) {
            addNewEntryOrCombine(finalList, val, tr["recipient"], "out", additional["tradeAddrCount"]);
          } else if(type == 11) {
            for(var transfer in tr["transfers"]) {
              addNewEntryOrCombine(finalList, transfer["amount"]/pow(10, decimals), transfer["recipient"], "out", additional["tradeAddrCount"]);
            }
          } else if(type == 7) {
            print("beb");
            addNewEntryOrCombine(finalList, val, tr["sender"], "out", additional["tradeAddrCount"]);
          } else if(type == 6) {
            addNewEntryOrCombine(finalList, val, "${tr["sender"]}", "out", additional["tradeAddrCount"]);
          }
        }

      }

      sum_in = sumacum_in.toStringAsFixed(2);
      sum_out = sumacum_out.toStringAsFixed(2);

    }

    String dir = direction == "all" ? "" : direction == "in" ? "incomes" : "outcomes";

    Widget out = RichText(
      text: TextSpan(
        style: TextStyle(fontSize: getLastFontSize()),
          children: [
            LblGroup(label: "Loaded transactions", val: allTrxLength.toString()),
            LblGroup(label: "Filtered transactions", val: filteredTrxLength.toString()),
            LblGroup(label: "from", val: fromDate),
            LblGroup(label: "to", val: toDate),
            LblGroup(label: "types", val: type),
            LblGroup(label: "assetName", val: assetNameStr),
            LblGroup(label: "function", val: functionName),
            LblGroup(label: "incomes", val: sum_in.toString()),
            LblGroup(label: "outcomes", val: sum_out.toString())
          ]
      ),
    );

    // return header + type + functionName + assetNameStr + fromDate + toDate + dir;
    return  out;
  }

  bool isFiltered() {
    // return fType != 0 || functName.isNotEmpty || assetName.isNotEmpty;
    return fType != 0 || functName.isNotEmpty || assetName.name.isNotEmpty || from != null || to != null;
  }

  notifyAll() {
    notifyListeners();
  }

  void changeOnlyTraders() {
    onlyTraders = !onlyTraders;
    notifyAll();
    _transactionProvider.filterTransactions();
  }

  void changeDirection(String val) {
    direction = val;
    notifyAll();
    _transactionProvider.filterTransactions();
  }

  void changeType(int val) {
    if(val != 3) {
      if(fType.contains(val)) {
        fType.remove(val);
      } else {
        fType.add(val);
      }
    } else {
      if(fType.contains(val)) {
        fType.remove(val); //3 - issue remove
        fType.remove(5); // 5 - reissue remove
      } else {
        fType.add(val); // 3 - issue add
        fType.add(5); // 5 - reissue add
      }
    }
    notifyAll();
    _transactionProvider.filterTransactions();
  }

  void clearType() {
    fType.clear();
    _transactionProvider.filterTransactions();
    notifyAll();
  }

  void changeFunctionName(val) {
    functName = val;
    _transactionProvider.filterTransactions();
    notifyAll();
  }

  void clearFunc() {
    functName = "";
    _transactionProvider.filterTransactions();
    notifyAll();
  }

  void changeAssetName(Asset? val) {
    assetName = val ?? Asset.empty();
    _transactionProvider.filterTransactions();
    notifyAll();
  }

  void clearAsset() {
    assetName;
    _transactionProvider.filterTransactions();
    notifyAll();
  }

  Future<void> changeFromDate(DateTime date) async{
    from = date;
    // _transactionProvider.filterTransactions();
    if (from!.isAfter(_transactionProvider.lastLoadedTransactionDate)) {
      _transactionProvider.filterTransactions();
    } else {
      _transactionProvider.allTransactions.clear();
      await _transactionProvider.getTransactions(address: _transactionProvider.curAddr);
    }
    notifyAll();
  }

  void changeToDate(DateTime date) {
    to = date;
    _transactionProvider.filterTransactions();
    notifyAll();
  }

  Future<void> clearFromDate() async{
    from = null;
    _transactionProvider.allTransactions.clear();
    await _transactionProvider.getTransactions(address: _transactionProvider.curAddr);
    notifyAll();
  }

  void clearToDate() {
    to = null;
    _transactionProvider.filterTransactions();
    notifyAll();
  }

  void changeReverse() {
    reverseTransactions = !reverseTransactions;
    _transactionProvider.allTransactions = _transactionProvider.allTransactions.reversed.toList();
    _transactionProvider.filterTransactions();
    _transactionProvider.notifyListeners();
    notifyAll();
  }

  void changeMinValue(String val) {
    // val ??= "0";
    if (val != "0") {
      minValue = val;
      _transactionProvider.filterTransactions();
      notifyAll();
    }
  }

  void clearMinValue() {
    minValue = "0";
    _transactionProvider.filterTransactions();
    notifyAll();
  }

  void addNewEntryOrCombine(Map<String, AddressesStatsItem> map, double val, String addr, String dir, int tradeAddrCount) {
    // print(map);
    // print(val);
    // print(addr);
    // print(dir);
    if(map.containsKey(addr)) {
      if (dir == "in") {
        map[addr]!.income = (map[addr]!.income + val);
      }
      if (dir == "out") {
        map[addr]!.outcome = (map[addr]!.outcome + val);
      }
    } else {
      if (dir == "in") {
        AddressesStatsItem it = AddressesStatsItem.income(addr, val, getAddrName(addr), tradeAddrCount);
        map[addr] = it;
      }
      if (dir == "out") {
        AddressesStatsItem it = AddressesStatsItem.outcome(addr, val, getAddrName(addr), tradeAddrCount);
        map[addr] = it;
      }
    }
  }

  void changeAddressName(val) {
    addrName = val;
    _transactionProvider.filterTransactions();
    notifyAll();
  }

  void clearAddress() {
    addrName = "";
    _transactionProvider.filterTransactions();
    notifyAll();
  }
  
}


