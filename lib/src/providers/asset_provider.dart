import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';

import '../models/asset.dart';

class AssetProvider extends ChangeNotifier{
  static final AssetProvider _instance = AssetProvider._internal();
  factory AssetProvider() {
    return _instance;
  }
  AssetProvider._internal();

  List<AccAsset> assets = List.empty(growable: true);
  List<AccAsset> filteredAssets = List.empty(growable: true);

  String assetNameId = "";

  changeNameFilter(String val) {
    assetNameId = val;
    filterAssets();
  }

  clearNameFilter() {
    assetNameId = "";
    filterAssets();
  }

  sortAssets() {
    assets.sort((a, b) {
      return a.asset!.name.compareTo(b.asset!.name);
    });
    assets.sort((a, b) {
      return b.priority.compareTo(a.priority);
    });
  }

  filterAssets() {
    filteredAssets = List.from(assets);
    if(assetNameId.isNotEmpty) {
      String nameLowered = assetNameId.toLowerCase();
      filteredAssets = assets.where((element) => element.asset!.name.toLowerCase().contains(nameLowered)).toList();
    }
    notifyListeners();
  }

}

