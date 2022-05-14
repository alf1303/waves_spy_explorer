import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';

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

  String createFilterData() {
    String type = fType == 0 ? "" : "Type: ${typeDict[fType].toString()}, ";
    String functionName = functName.isEmpty ? "" : "Call: $functName, ";
    String assetNameStr = assetName.isEmpty ? "" : "Asset: $assetName, ";
    String fromDate = from == null ? "" : "From: ${from.toString()}, ";
    String toDate = to == null ? "" : "To: ${to.toString()}, ";
    return "Filter: " + type + functionName + assetNameStr + fromDate + toDate;
  }

  bool isFiltered() {
    return fType != 0 || functName.isNotEmpty || assetName.isNotEmpty;
  }

  notifyAll() {
    notifyListeners();
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

