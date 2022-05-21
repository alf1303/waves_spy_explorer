import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/styles.dart';
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

  Map<String, double> finalList = {};
  double sumacum = 0;
  //create string for indicating current filter parameters
  Widget createFilterData(int allTrxLength, int filteredTrxLength) {
    final types = fType.map((e) => typeDict[e]).join(", ");
    String sum = "";

    Widget typeW = fType.isEmpty ? Container() : LabeledText("types: ", "$types, ");
    Widget functionNameW = functName.isEmpty ? Container() : LabeledText("call: ", "$functName, ");
    Widget assetNameStrW = assetName.isEmpty ? Container() : LabeledText("asset: ", "$assetName, ");
    Widget fromDateW = actualFrom == null ? Container() : LabeledText("from: ", getFormattedDate(actualFrom));
    Widget toDateW = actualTo == null ? Container() : LabeledText("to: ", getFormattedDate(actualTo));

    //Calculating income/outcome summs
    if(assetName.isNotEmpty && direction != "all") {
      sumacum = 0;
      String assId = "";
      for (var tr in _transactionProvider.filteredTransactions) {
        if(direction == "in") {
            assId = tr["inAssetsIds"].keys.toList()[0];
            sumacum += tr["inAssetsIds"][assId];
            if(finalList.containsKey(tr["sender"])) {
              finalList[tr["sender"]] = (finalList[tr["sender"]]! + tr["inAssetsIds"][assId]!);
            } else {
              finalList[tr["sender"]] = tr["inAssetsIds"][assId];
            }
        }

        if(direction == "out") {
          assId = tr["outAssetsIds"].keys.toList()[0];
          sumacum += tr["outAssetsIds"][assId];
          if(finalList.containsKey(tr["sender"])) {
            finalList[tr["sender"]] = (finalList[tr["sender"]]! + tr["outAssetsIds"][assId]!);
          } else {
            finalList[tr["sender"]] = tr["outAssetsIds"][assId];
          }
        }
      }

      int decimals = assetsGlobal[assId] == null ? 1 : assetsGlobal[assId]!.decimals;
      finalList.updateAll((key, value) => value/pow(10, decimals));
      sumacum = sumacum/pow(10, decimals);
      sum = sumacum.toStringAsFixed(5);
    }

    Widget headerW = Row(children: [
      LabeledText("Loaded transactions: ", "${allTrxLength.toString()}, "),
      LabeledText("Filtered transactions: ", "${filteredTrxLength.toString()}"),
    ],);
    Widget dirW = direction == "all" ? Container() : direction == "in" ? LabeledText("incomes: $sum") : LabeledText("outcomes: $sum");
    Widget out = Column(children: [
      headerW,
      Row(children: [typeW, functionNameW, assetNameStrW, fromDateW, toDateW, dirW])
    ]);
    // return "Filter options: " + type + functionName + assetNameStr + fromDate + toDate + dir + sum;
    return  out;
  }

  Widget createFilterDataString(int allTrxLength, int filteredTrxLength) {
    final types = fType.map((e) => typeDict[e]).join(", ");
    String sum = "";

    String type = fType.isEmpty ? "" : types;
    String functionName = functName.isEmpty ? "" : functName;
    String assetNameStr = assetName.isEmpty ? "" : assetName;
    String fromDate = actualFrom == null ? "" : getFormattedDate(actualFrom);
    String toDate = actualTo == null ? "" : getFormattedDate(actualTo);

    //Calculating income/outcome summs
    if(assetName.isNotEmpty && direction != "all") {
      sumacum = 0;
      String assId = "";
      for (var tr in _transactionProvider.filteredTransactions) {
        if(direction == "in") {
          assId = tr["inAssetsIds"].keys.toList()[0];
          sumacum += tr["inAssetsIds"][assId];
          if(finalList.containsKey(tr["sender"])) {
            finalList[tr["sender"]] = (finalList[tr["sender"]]! + tr["inAssetsIds"][assId]!);
          } else {
            finalList[tr["sender"]] = tr["inAssetsIds"][assId];
          }
        }

        if(direction == "out") {
          assId = tr["outAssetsIds"].keys.toList()[0];
          sumacum += tr["outAssetsIds"][assId];
          if(finalList.containsKey(tr["sender"])) {
            finalList[tr["sender"]] = (finalList[tr["sender"]]! + tr["outAssetsIds"][assId]!);
          } else {
            finalList[tr["sender"]] = tr["outAssetsIds"][assId];
          }
        }
      }

      int decimals = assetsGlobal[assId] == null ? 1 : assetsGlobal[assId]!.decimals;
      finalList.updateAll((key, value) => value/pow(10, decimals));
      sumacum = sumacum/pow(10, decimals);
      sum = sumacum.toStringAsFixed(5);
    }

    String dir = direction == "all" ? "" : direction == "in" ? "incomes" : "outcomes";

    Widget out = RichText(
      text: TextSpan(
          children: [
            LblGroup("Loaded transactions", allTrxLength.toString()),
            LblGroup("Filtered transactions", filteredTrxLength.toString()),
            LblGroup("from", fromDate),
            LblGroup("to", toDate),
            LblGroup("types", type),
            LblGroup("assetName", assetNameStr),
            LblGroup("function", functionName),
            LblGroup(dir, sum.toString())
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

}

TextSpan  LblGroup(String label, String val) {
  return val.isEmpty ? TextSpan() : TextSpan(
    children: [
      TextSpan(
        style: TextStyle(color: Colors.grey),
        text: label + ": "
      ),
      TextSpan(
        style: TextStyle(color: Colors.white),
        text: val + ", "
      )
    ]
  );
}

