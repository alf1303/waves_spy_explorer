class Nft {
  dynamic data;
  bool isDuck = false;
  bool isFarming = false;
  bool isDjedi = false;
  bool isEagle = false;
  int mantleLvl = 0;
  int farmingPower = 0;

  Nft.common(this.data);

  Nft.jedi({this.data, required this.isDuck, required this.isDjedi, required this.mantleLvl});

  Nft({this.data, required this.isDuck, required this.isFarming, required this.farmingPower});
}