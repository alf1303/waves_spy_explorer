class AddressesStatsItem {
  String address = "";
  double income = 0;
  double outcome = 0;
  String name = "";
  int tradeAddrCount = 0;

  AddressesStatsItem.income(this.address, this.income, this.name, this.tradeAddrCount);

  AddressesStatsItem.outcome(this.address, this.outcome, this.name, this.tradeAddrCount);
}