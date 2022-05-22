import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/data/data_view.dart';


class StatsProvider extends ChangeNotifier{
  static final StatsProvider _instance = StatsProvider._internal();
  factory StatsProvider() {
    return _instance;
  }
  StatsProvider._internal();

  int freeDucksCount = 0;
  int stakedDucksCount = 0;
  Map<String, int> calls = {};

  notifyAll() {
    notifyListeners();
  }

}

