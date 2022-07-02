import 'package:flutter/material.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/models/chart_item.dart';

class PuzzleProvider extends ChangeNotifier{
  static final PuzzleProvider _instance = PuzzleProvider._internal();
  factory PuzzleProvider() {
    return _instance;
  }
  PuzzleProvider._internal();

  String poolName = "";
  String userName = "";
  List<DataItem> dappList = List.empty(growable: true);
  List<DataItem> userList = List.empty(growable: true);
  List<DataItem> filteredDappList = List.empty(growable: true);
  List<DataItem> filteredUserList = List.empty(growable: true);
  int lastEaglesStaked = 0;
  int lastAniasStaked = 0;

  //charts data
  Map<String, List<dynamic>> burnData = {};
  List<ChartItem> puzzleData = List.empty(growable: true);
  List<AggregatorItem> aggregatorData = List.empty(growable: true);

  double getPuzzleEarningsSum() {
    double sum = 0;
    for(ChartItem it in puzzleData) {
      sum += it.value;
    }
    return sum;
  }

  void setDappList(List<DataItem> list) {
    for(DataItem item in list) {
      final name = getAddrName(item.address);
      final namestr = name.isEmpty ? "" : "($name)";
      item.address = item.address + namestr;
    }
    dappList = list;
    filter();
  }

  void setUserList(List<DataItem> list) {
    userList = list;
    filter();
  }

  void changePoolName(str) {
    poolName = str;
    filter();
  }

  void changeUserName(str) {
    userName = str;
    filter();
  }

  void clearPool() {
    poolName = "";
    filter();
  }

  void clearUser() {
    userName = "";
    filter();
  }

  void filter() {
    if(poolName.isNotEmpty) {
      filteredDappList = dappList.where((element) => element.address.toLowerCase().contains(poolName.toLowerCase())).toList();
    } else {
      filteredDappList = [...dappList];
    }
    if(userName.isNotEmpty) {
      filteredUserList = userList.where((element) => element.address.toLowerCase().contains(userName.toLowerCase())).toList();
    } else {
      filteredUserList = [...userList];
    }
    // print(filteredDappList.length);
    notify();
  }

  notify() {
    notifyListeners();
  }

}