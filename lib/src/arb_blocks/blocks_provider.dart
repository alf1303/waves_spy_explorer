import 'package:flutter/material.dart';

class BlocksProvider extends ChangeNotifier{
  static final BlocksProvider _instance = BlocksProvider._internal();
  factory BlocksProvider() {
    return _instance;
  }
  BlocksProvider._internal();

  int block = 1;
  String txid = "";
  bool byBlock = true;

  notifyAll() {
    notifyListeners();
  }

}

