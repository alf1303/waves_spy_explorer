import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/styles.dart';

import '../models/asset.dart';

class FilterProvider extends ChangeNotifier{
  static final FilterProvider _instance = FilterProvider._internal();
  factory FilterProvider() {
    return _instance;
  }
  FilterProvider._internal();
  final _transactionProvider = TransactionProvider();
  DateTime? from;
  DateTime? to;
  int fType = 0;
  String functName = "";
  String assetName = "";
  String direction = "all";

  //create string for indicating current filter parameters
  String createFilterData() {
    String type = fType == 0 ? "" : "Type: ${typeDict[fType].toString()}, ";
    String functionName = functName.isEmpty ? "" : "Call: $functName, ";
    String assetNameStr = assetName.isEmpty ? "" : "Asset name: $assetName, ";
    String fromDate = from == null ? "" : "From: ${from.toString()}, ";
    String toDate = to == null ? "" : "To: ${to.toString()}, ";
    String dir = direction == "all" ? "" : direction == "in" ? "incomes" : "outcomes";
    String sum = "";
    // TODO fix this to include/
    if(assetName.isNotEmpty && direction != "all") {
      double sumacum = 0;
      String assId = "";
      for (var tr in _transactionProvider.filteredTransactions) {
        if(direction == "in") {
          assId = tr["inAssetsIds"].keys.toList()[0];
          sumacum += tr["inAssetsIds"][assId];
        }
        if(direction == "out") {
          assId = tr["outAssetsIds"].keys.toList()[0];
          sumacum += tr["ouAssetsIds"][assId];
        }
      }
      int decimals = assetsGlobal[assId] == null ? 1 : assetsGlobal[assId]!.decimals;
      sumacum = sumacum/pow(10, decimals);
      sum = sumacum.toStringAsFixed(5);
    }
    return "Filter options: " + type + functionName + assetNameStr + fromDate + toDate + dir + sum;
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
    fType = val;
    notifyAll();
    _transactionProvider.filterTransactions();
  }

  void clearType() {
    fType = 0;
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

