import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';

import '../models/asset.dart';

class ProgressProvider extends ChangeNotifier{
  static final ProgressProvider _instance = ProgressProvider._internal();
  factory ProgressProvider() {
    return _instance;
  }
  ProgressProvider._internal();
  bool loading = false;
  bool loadingTrans = false;
  bool loadingAssets = false;
  bool loadingNfts = false;
  bool loadingData = false;
  bool loadingScript = false;

  void start() {
    loading = true;
    notify();
  }

  void stop() {
    loading = false;
    notify();
  }

  void startTransactions() {
    loadingTrans = true;
    notify();
  }

  void stopTransactions() {
    loadingTrans = false;
    notify();
  }

  void startAssets() {
    loadingAssets = true;
    notify();
  }

  void stopAssets() {
    loadingAssets = false;
    notify();
  }

  void startNfts() {
    loadingNfts = true;
    notify();
  }

  void stopNfts() {
    loadingNfts = false;
    notify();
  }

  void startData() {
    loadingData = true;
    notify();
  }

  void stopData() {
    loadingData = false;
    notify();
  }

  void startScript() {
    loadingScript = true;
    notify();
  }

  void stopScript() {
    loadingScript = false;
    notify();
  }

  notify() {
    notifyListeners();
  }

  getBool(String label) {
    switch(label) {
      case "main":
        return loading;
      case "trans":
        return loadingTrans;
      case "assets":
        return loadingAssets;
      case "nfts":
          return loadingNfts;
      case "data":
        return loadingData;
      case "script":
        return loadingScript;
      default:
        return false;
    }
  }

  bool isPresent(String label) {
    return isPresentData(label);
  }

  int getLoadedItemsCountProxy(String label) {
    return getLoadedItemsCount(label);
  }

  bool allTransactionsLoadedProxy() {
    return allTransactionsLoaded();
  }
}