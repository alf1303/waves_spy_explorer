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
  String minValue = "0";

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
      for (var tr in _transactionProvider.filteredTransactions) {
        int type = tr["type"];
        if(tr["inAssetsIds"].containsKey(assetName.id)) {
          // assId = tr["inAssetsIds"].keys.toList()[0];
          int decimals = assetsGlobal[assId] == null ? 1 : assetsGlobal[assId]!.decimals;
          double val = tr["inAssetsIds"][assId]/pow(10, decimals);
          sumacum_in += tr["inAssetsIds"][assId]/pow(10, decimals);
          if(type == 16 && tr["dApp"] == _transactionProvider.curAddr) {
            addNewEntryOrCombine(finalList, val, tr["sender"], "in");
          } else if(type == 16) {
            addNewEntryOrCombine(finalList, val, tr["dApp"], "in");
          } else {
            addNewEntryOrCombine(finalList, val, tr["sender"], "in");
          }
        }
        if(tr["outAssetsIds"].containsKey(assetName.id)) {
          // assId = tr["outAssetsIds"].keys.toList()[0];
          int decimals = assetsGlobal[assId] == null ? 1 : assetsGlobal[assId]!.decimals;
          double val = tr["outAssetsIds"][assId]/pow(10, decimals);
          sumacum_out += val;
          if (type == 16 && tr["dApp"] == _transactionProvider.curAddr) {
            addNewEntryOrCombine(finalList, val, tr["sender"], "out");
          } else if(type == 16) {
            addNewEntryOrCombine(finalList, val, tr["dApp"], "out");
          } else if(type == 4) {
            addNewEntryOrCombine(finalList, val, tr["recipient"], "out");
          } else if(type == 11) {
            for(var transfer in tr["transfers"]) {
              addNewEntryOrCombine(finalList, transfer["amount"], transfer["recipient"], "out");
            }
          } else if(type == 7) {
            addNewEntryOrCombine(finalList, val, tr["sender"], "out");
          } else if(type == 6) {
            addNewEntryOrCombine(finalList, val, "Burn, baby, burn", "out");
          }
        }
      }

      sum_in = sumacum_in.toStringAsFixed(2);
      sum_out = sumacum_out.toStringAsFixed(2);

    }

    String dir = direction == "all" ? "" : direction == "in" ? "incomes" : "outcomes";

    Widget out = RichText(
      text: TextSpan(
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

  void changeDirection(String val) {
    direction = val;
    notifyAll();
    _transactionProvider.filterTransactions();
  }

  void changeType(int val) {
    if(fType.contains(val)) {
      fType.remove(val);
    } else {
      fType.add(val);
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
    _transactionProvider.allTransactions.clear();
    await _transactionProvider.getTransactions(address: _transactionProvider.curAddr);
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

  void addNewEntryOrCombine(Map<String, AddressesStatsItem> map, double val, String addr, String dir) {
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
        AddressesStatsItem it = AddressesStatsItem.income(addr, val, getAddrName(addr));
        map[addr] = it;
      }
      if (dir == "out") {
        AddressesStatsItem it = AddressesStatsItem.outcome(addr, val, getAddrName(addr));
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


