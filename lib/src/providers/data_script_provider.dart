import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/data/data_view.dart';


class DataScriptProvider extends ChangeNotifier{
  static final DataScriptProvider _instance = DataScriptProvider._internal();
  factory DataScriptProvider() {
    return _instance;
  }
  DataScriptProvider._internal();

  List<dynamic> data = List.empty(growable: true);
  dynamic script = "";
  List<dynamic> filteredList = List.empty(growable: true);

  String dataName = "";

  changeNameFilter(String val) {
    dataName = val;
    filterData();
  }

  clearNameFilter() {
    dataName = "";
    filterData();
  }

  getItem(item) {
    return DataView(data: item);
  }

  // sortNfts() {
  //   data.sort((a, b) {
  //     return a["name"].compareTo(b["name"]);
  //   });
  // }

  filterData() {
    filteredList = List.from(data);
    if(dataName.isNotEmpty) {
      String logop = "";
      String nameLowered = dataName.toLowerCase();
      List<String> ops = List.empty(growable: true);
      if(nameLowered.contains("&&&")) {
        logop = "&";
        ops = nameLowered.split("&&&");
      }
      if(nameLowered.contains("|||")) {
        logop = "|";
        ops = nameLowered.split("|||");
      }
      if(logop == "") {
        filteredList = data.where((element) => (element["key"].toLowerCase().contains(nameLowered) || element["value"].toString().toLowerCase().contains(nameLowered))).toList();
      } else if(logop == "&") {
        filteredList.clear();
        for(var ele in data) {
          bool flag = true;
          for(var op in ops) {
            if(op.isNotEmpty) {
              flag = flag && ele["key"].toLowerCase().contains(op);
            }
          }
          if (flag) {
            filteredList.add(ele);
          }
        }
      } else if (logop == "|") {
        filteredList.clear();
        for(var ele in data) {
          bool flag = false;
          for(var op in ops) {
            if(op.isNotEmpty) {
              flag = flag || ele["key"].toLowerCase().contains(op);
            }
          }
          if (flag) {
            filteredList.add(ele);
          }
        }
      }
    }
    notifyListeners();
  }

}

