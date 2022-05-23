import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
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
  String assetName = "";
  String direction = "all";
  bool reverseTransactions = false;
  double minValue = 0;

  Map<String, double> finalList = {};
  double sumacum = 0;

  //create RichText for indicating current filter parameters
  Widget createFilterDataString(int allTrxLength, int filteredTrxLength) {
    final types = fType.map((e) => typeDict[e]).join(", ");
    String sum = "";

    String type = fType.isEmpty ? "" : types;
    String functionName = functName.isEmpty ? "" : functName;
    String assetNameStr = assetName.isEmpty ? "" : assetName;
    String fromDate = actualFrom == null ? "" : getFormattedDate(actualFrom);
    String toDate = actualTo == null ? "" : getFormattedDate(actualTo);

    //Calculating income/outcome summs
    finalList.clear();
    if(assetName.isNotEmpty && direction != "all") {
      sumacum = 0;
      String assId = "";
      for (var tr in _transactionProvider.filteredTransactions) {
        if(direction == "in") {
          assId = tr["inAssetsIds"].keys.toList()[0];
          int decimals = assetsGlobal[assId] == null ? 1 : assetsGlobal[assId]!.decimals;
          double val = tr["inAssetsIds"][assId]/pow(10, decimals);
          sumacum += tr["inAssetsIds"][assId]/pow(10, decimals);
          if(finalList.containsKey(tr["sender"])) {
            finalList[tr["sender"]] = (finalList[tr["sender"]]! + val);
          } else {
            finalList[tr["sender"]] = val;
          }
        }

        if(direction == "out") {
          assId = tr["outAssetsIds"].keys.toList()[0];
          int decimals = assetsGlobal[assId] == null ? 1 : assetsGlobal[assId]!.decimals;
          double val = tr["outAssetsIds"][assId]/pow(10, decimals);
          sumacum += val;
          int type = tr["type"];
          if (type == 16 && tr["dApp"] == _transactionProvider.curAddr) {
            addNewEntryOrCombine(finalList, val, tr["sender"]);
          } else if(type == 16) {
            addNewEntryOrCombine(finalList, val, tr["dApp"]);
          } else if(type == 4) {
            addNewEntryOrCombine(finalList, val, tr["recipient"]);
          } else if(type == 11) {
            for(var transfer in tr["transfers"]) {
              addNewEntryOrCombine(finalList, transfer["amount"], transfer["recipient"]);
            }
          } else if(type == 7) {
            addNewEntryOrCombine(finalList, val, tr["sender"]);
          } else if(type == 6) {
            addNewEntryOrCombine(finalList, val, "Burn, baby, burn");
          }
        }
      }

      int decimals = assetsGlobal[assId] == null ? 1 : assetsGlobal[assId]!.decimals;
      print("decimals: $decimals");
      // finalList.updateAll((key, value) => value/pow(10, decimals));
      // sumacum = sumacum/pow(10, decimals);
      sum = sumacum.toStringAsFixed(5);
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
            LblGroup(label: dir, val: sum.toString())
          ]
      ),
    );

    // return header + type + functionName + assetNameStr + fromDate + toDate + dir;
    return  out;
  }

  bool isFiltered() {
    // return fType != 0 || functName.isNotEmpty || assetName.isNotEmpty;
    return fType != 0 || functName.isNotEmpty || assetName.isNotEmpty || from != null || to != null;
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

  void changeAssetName(val) {
    assetName = val;
    _transactionProvider.filterTransactions();
    notifyAll();
  }

  void clearAsset() {
    assetName = "";
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

  void changeMinValue(val) {
    val ??= 0;
    if (val != null && val != "" && val != 0) {
      minValue = double.parse(val);
      _transactionProvider.filterTransactions();
      notifyAll();
    }
  }

  void clearMinValue() {
    minValue = 0;
    _transactionProvider.filterTransactions();
    notifyAll();
  }

  void addNewEntryOrCombine(Map<String, double> map, double val, String addr) {
    if(map.containsKey(addr)) {
      map[addr] = (map[addr]! + val);
    } else {
      map[addr] = val;
    }
  }
  
}


