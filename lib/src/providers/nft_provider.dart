import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';


class NftProvider extends ChangeNotifier{
  static final NftProvider _instance = NftProvider._internal();
  factory NftProvider() {
    return _instance;
  }
  NftProvider._internal();

  List<dynamic> nfts = List.empty(growable: true);
  List<dynamic> filteredNfts = List.empty(growable: true);

  String nftName = "";

  changeNameFilter(String val) {
    nftName = val;
    filterNfts();
  }

  clearNameFilter() {
    nftName = "";
    filterNfts();
  }

  sortNfts() {
    nfts.sort((a, b) {
      return a["name"].compareTo(b["name"]);
    });
  }

  filterNfts() {
    filteredNfts = List.from(nfts);
    if(nftName.isNotEmpty) {
      String nameLowered = nftName.toLowerCase();
      filteredNfts = nfts.where((element) => element["name"].toLowerCase().contains(nameLowered)).toList();
    }
    notifyListeners();
  }

}

