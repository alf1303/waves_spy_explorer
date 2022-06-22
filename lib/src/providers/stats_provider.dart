import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/farmStakingItem.dart';
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
  int jediDucksCount = 0;
  Map<String, int> calls = {};
  List<FarmStakingItem> stakes = List.empty(growable: true);

  //hatch, breed, reborn, perch buy
  Map<String, StatsItem> duckStatsItems = {};
  Map<String, int> rebirthResults = {};

  Future<List<FarmStakingItem>?> getFarmStakingData(addr) async{
     stakes = List.empty(growable: true);
    final transactionProvider = TransactionProvider();
    const scale = 100000000;
    List<String> addresses = farmStakingDapps.keys.toList();
    var resp, reqstr;
    for(String adr in addresses) {
      reqstr = "$nodeUrl/addresses/data/$adr";
      int attempts = 5;
      while(attempts > 0) {
        try {
          resp = await http.get(Uri.parse(reqstr));
          attempts = 0;
        } catch(err) {
          attempts -= 1;
          print("Catched XMLHttpRequest error, retrying... $attempts left");
        }
      }
      if(resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        double staked = 0, claimed = 0, lastCheck = 0, globalLastCheck = 0, available = 0;
        final stakedKey = "${transactionProvider.curAddr}_farm_staked";
        final claimedKey = "${transactionProvider.curAddr}_claimed";
        final lastCheckInterest = "${transactionProvider.curAddr}_lastCheck_interest";
        const globalInterest = "global_lastCheck_interest";
        for(var el in json) {
          if(el["key"] == stakedKey) {staked = el["value"];}
          if(el["key"] == claimedKey) {claimed = el["value"];}
          if(el["key"] == lastCheckInterest) {lastCheck = el["value"];}
          if(el["key"] == globalInterest) {globalLastCheck = el["value"];}
          available = ((globalLastCheck - lastCheck) * staked )/ scale;
        }
        if(staked > 0 || claimed > 0 || available > 0) {
          stakes.add(FarmStakingItem(farmName: getAddrName(adr), staked: staked, claimed: claimed, available: available));
        }
      } else {
        print("Error loading data storage for dApp: $adr, msg: $resp");
      }
    }
    print("Stakes length: ${stakes.length}");
    return stakes;
  }

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
    jediDucksCount = 0;
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

