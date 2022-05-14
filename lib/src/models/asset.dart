import 'dart:math';

class Asset{
  String id;
  String name;
  String description;
  bool reissuable;
  int decimals;
  int? scale;

  Asset(this.id, this.name, this.decimals, this.description, this.reissuable) {
    scale = pow(10, decimals).toInt();
  }
}