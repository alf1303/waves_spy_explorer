import 'dart:math';

class Asset{
  String id = "";
  String name = "";
  String description = "";
  bool reissuable = false;
  bool scripted = false;
  int decimals = 0;
  int? scale;


  Asset.empty() {
    id = "";
    name = "";
    description = "";
    reissuable = false;
    scripted = false;
    decimals = 0;
    scale = 1;
  }

  Asset(this.id, this.name, this.decimals, this.description, this.reissuable, this.scripted) {
    scale = pow(10, decimals).toInt();
  }
}

class AccAsset {
  Asset? asset;
  int priority = 0;
  int amount = 0;
  int staked = 0;
  dynamic data;

  AccAsset(this.asset, this.amount, this.priority, this.data);
}