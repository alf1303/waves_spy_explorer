import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';

class TransactionProvider extends ChangeNotifier{
  static final TransactionProvider _instance = TransactionProvider._internal();
  factory TransactionProvider() {
    return _instance;
  }
  TransactionProvider._internal();
  String curAddr = "";

  List<dynamic> allTransactions = List.empty(growable: true);
  List<dynamic> nft = List.empty(growable: true);
  List<dynamic> assets = List.empty(growable: true);
  List<dynamic> data = List.empty(growable: true);
  String script = "";
  dynamic wavesBalance = {
    "regular": 0,
    "generating": 0,
    "available": 0,
    "effective": 0};

  Future<void> setCurrAddr(String address) async{
    curAddr = address;
    await getTransactions(curAddr);
    await getAssets(curAddr);
    // await getNft(curAddr); //implement
    // await getData(curAddr); //implement
    // await getScript(curAddr); //implement
    notifyListeners();
  }

  Future<void> getTransactions(String address, [limit, after]) async {
    limit = limit ?? 50;
    after = after ?? "";
    var res = <dynamic>[];
    var resp = await http.get(Uri.parse("$nodeUrl/transactions/address/$address/limit/$limit?after=$after"));
    // print(resp.body);
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      res = json[0];
    } else {
      throw("Failed to load transactions list\n" + resp.body);
    }
    if (after == "") {
      allTransactions = res;
    } else {
      allTransactions.addAll(res);
    }
    // allTransactions = allTransactions.where((element) => element["type"] == 16).toList();
  }

  Future<void> getAssets(String address) async {
    var res = <dynamic>[];
    var resp = await http.get(Uri.parse("$nodeUrl/assets/balance/$address"));
    if(resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      // print(resp.body);
      res = json["balances"];
      assets = res;
    } else {
      throw("Failed to load assets list. \n" + resp.body);
    }
  }

  Future<void> getNft(String address) async{}

  getData(String address) {}

  getScript(String address) {}
}