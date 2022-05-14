import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';

import '../models/asset.dart';

class ProgressProvider extends ChangeNotifier{
  static final ProgressProvider _instance = ProgressProvider._internal();
  factory ProgressProvider() {
    return _instance;
  }
  ProgressProvider._internal();
  bool loadingTrans = false;

  void start() {
    loadingTrans = true;
    notify();
  }

  void stop() {
    loadingTrans = false;
    notify();
  }

  notify() {
    notifyListeners();
  }
}