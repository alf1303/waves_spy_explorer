import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/nft.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/nfts/nft_view.dart';


class NftProvider extends ChangeNotifier{
  static final NftProvider _instance = NftProvider._internal();
  factory NftProvider() {
    return _instance;
  }
  NftProvider._internal();

  List<Nft> nfts = List.empty(growable: true);
  List<Nft> filteredList = List.empty(growable: true);

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
      return a.data["name"].compareTo(b.data["name"]);
    });
  }

  filterNfts() {
    filteredList = List.from(nfts);
    if(nftName.isNotEmpty) {
      String nameLowered = nftName.toLowerCase();
      filteredList = nfts.where((element) => element.data["name"].toLowerCase().contains(nameLowered)).toList();
    }
    notifyListeners();
  }

  getItem(item) {
    return NftView(nft: item);
  }

}

