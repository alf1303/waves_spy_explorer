import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BlocksProvider extends ChangeNotifier{
  static final BlocksProvider _instance = BlocksProvider._internal();
  factory BlocksProvider() {
    return _instance;
  }
  BlocksProvider._internal();

  int block = 1;
  String txid = "";
  bool byBlock = true;
  List<String> wxPools = List.empty(growable: true);


  notifyAll() {
    notifyListeners();
  }

  Map<String, dynamic> getAssetData(String? assetId) {
    Map<String, dynamic> result = {};
    if (assetId == "WAVES") {
      result["name"] = "WAVES";
      result["decimals"] = 8;
    }
    if (assetId == null) {
      result["name"] = "WAVES";
      result["decimals"] = 8;
    }
    if (assetId == "DG2xFkPdDwKUoBkzGAhQtLpSGzfXLiCYPEzeKH2Ad24p") {
      result["name"] = "XTN.";
      result["decimals"] = 6;
    }
    if (assetId == "9wc3LXNA4TEBsXyKtoLE9mrbDD7WMHXvXrCjZvabLAsi") {
      result["name"] = "USDT";
      result["decimals"] = 6;
    }
    return result;
  }

  String getPoolType(String identificator) {
    final puzzle = ["P"];
    final wx = ["W"];
    final swopfi = ["S"];
    final tsn = ["T"];
    if (puzzle.contains(identificator)) {
      return "puzzle";
    }
    if (wx.contains(identificator)) {
      return "wx";
    }
    if (swopfi.contains(identificator)) {
      return "swopfi";
    }
    if (tsn.contains(identificator)) {
      return "tsunami";
    }
    return "unknown";
  }


  Future<Map<String, dynamic>> getTxData(String txid) async {
    final reqStr = "https://nodes.wavesnodes.com/transactions/info/" + txid;
    var resp = await http.get(Uri.parse(reqStr));
    Map<String, dynamic> result = {};
    // print(resp);
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      result = json;

    } else {
      print("Some error_loading wxPools: " + resp.body);
    }
    return result;
  }

  // Future<Map<String, dynamic>> getAssetData(String assetId) async {
  //   final reqStr = "https://nodes.wavesnodes.com/assets/details/" + assetId;
  //   var resp = await http.get(Uri.parse(reqStr));
  //   Map<String, dynamic> result = {};
  //   // print(resp);
  //   if (resp.statusCode == 200) {
  //     final json = jsonDecode(resp.body);
  //     result = json;
  //
  //   } else {
  //     print("Some error_loading assetData: " + resp.body);
  //   }
  //   return result;
  // }

  Future<List<String>> getWxPools() async {
    final reqStr = "https://wx.network/api/v1/liquidity_pools/stats/";
    var resp = await http.get(Uri.parse(reqStr));
    List<String> result = List.empty(growable: true);
    // print(resp);
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      final items = json["items"];
      result = items.map<String>((el) => el["address"].toString()).toList();

    } else {
      print("Some error_loading wxPools: " + resp.body);
    }
    wxPools = result;
    return result;
  }

}

