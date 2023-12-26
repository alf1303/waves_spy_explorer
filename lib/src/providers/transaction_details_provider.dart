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
    print("details 2");
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    print("details 3");
    var trs2 = {...trs};
    trs2.remove("additional");
    final stChngs = trs["stateChanges"] ?? {};
    final error = stChngs["error"] ?? {"error": "None"};
    final err = encoder.convert(error);
    tr = encoder.convert(trs2);
    tr = err + "\n" + tr;
    print("details 4");
    notifyListeners();
  }

  setFullTransaction() {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    tr = encoder.convert(trsHold);
    notifyListeners();
  }

}

