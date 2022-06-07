import 'package:flutter/material.dart';

class LabelProvider extends ChangeNotifier{
  static final LabelProvider _instance = LabelProvider._internal();
  factory LabelProvider() {
    return _instance;
  }
  LabelProvider._internal();

  bool isAddressPresent = false;
  notify() {
    notifyListeners();
  }

}