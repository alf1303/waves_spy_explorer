import 'dart:math';

class Asset{
  String id;
  String name;
  String description;
  bool reissuable;
  bool scripted;
  int decimals;
  int? scale;

  Asset(this.id, this.name, this.decimals, this.description, this.reissuable, this.scripted) {
    scale = pow(10, decimals).toInt();
  }
}

class AccAsset {
  Asset? asset;
  int priority = 0;
  int amount = 0;
  int staked = 0;

  AccAsset(this.asset, this.amount, this.priority);
}