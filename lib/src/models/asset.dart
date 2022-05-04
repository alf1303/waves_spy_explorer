import 'dart:math';

class Asset{
  String id;
  String name;
  int decimals;
  int? scale;
  Asset? priceAsset; //for exchange transactions calculations

  Asset(this.id, this.name, this.decimals) {
    scale = pow(10, decimals).toInt();
  }
}

class TmpAss{
  String id;
  String priceId;

  TmpAss(this.id, this.priceId);
}