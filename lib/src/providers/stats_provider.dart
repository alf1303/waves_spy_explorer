import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/stats_item.dart';
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

  //hatch, breed, reborn, perch buy
  Map<String, StatsItem> duckStatsItems = {};
  Map<String, int> rebirthResults = {};

  void updateDuckStats(String label, int count, double amount) {
    if(duckStatsItems.containsKey(label)) {
      duckStatsItems[label]!.count = duckStatsItems[label]!.count + 1;
      duckStatsItems[label]!.amount = duckStatsItems[label]!.amount + amount;
    } else {
      StatsItem it = StatsItem(name: label, count: count, amount: amount);
      duckStatsItems[label] = it;
    }
  }

  void updateRebirthResults(String label) {
    if(rebirthResults.containsKey(label)) {
      rebirthResults[label] = rebirthResults[label]! + 1;
    } else {
      rebirthResults[label] = 1;
    }
  }

  void clearState() {
    duckStatsItems.clear();
    rebirthResults.clear();
    calls.clear();
    freeDucksCount = 0;
    stakedDucksCount = 0;
  }

  void addCall(String call) {
    if(calls.containsKey(call)) {
      calls[call] = calls[call]! + 1;
    } else {
      calls[call] = 1;
    }
  }

  notifyAll() {
    notifyListeners();
  }

}

