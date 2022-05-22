class Nft {
  dynamic data;
  bool isDuck = false;
  bool isFarming = false;
  int farmingPower = 0;

  Nft.common(this.data);

  Nft({this.data, required this.isDuck, required this.isFarming, required this.farmingPower});
}