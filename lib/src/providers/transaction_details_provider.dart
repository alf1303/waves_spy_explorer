import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';

import '../models/asset.dart';

class TransactionDetailsProvider extends ChangeNotifier{
  static final TransactionDetailsProvider _instance = TransactionDetailsProvider._internal();
  factory TransactionDetailsProvider() {
    return _instance;
  }
  TransactionDetailsProvider._internal();
  final _transactionProvider = TransactionProvider();

  String tr = "";
  Map<String, dynamic> trsHold = {};

  setTransaction(Map<String, dynamic>trs) {
    trsHold = trs;
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    var trs2 = {...trs};
    trs2.remove("additional");
    tr = encoder.convert(trs2);
    notifyListeners();
  }

  setFullTransaction() {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    tr = encoder.convert(trsHold);
    notifyListeners();
  }

}

