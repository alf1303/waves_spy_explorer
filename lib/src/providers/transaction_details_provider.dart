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

  setTransaction(trs) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    tr = encoder.convert(trs);

    notifyListeners();
  }

}

