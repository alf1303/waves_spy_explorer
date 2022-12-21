class ChartItem {
  DateTime date;
  double value;

  ChartItem({required this.date, required this.value});

  factory ChartItem.fromMap(Map<String, dynamic> json) {
    return ChartItem(date: DateTime.parse(json["date"]), value: double.parse(json["value"]));
  }
}

class AggregatorItem {
  DateTime date;
  double value;
  int eaglesStaked;
  int aniasStaked;

  AggregatorItem({required this.date, required this.value, required this.eaglesStaked, required this.aniasStaked});

  factory AggregatorItem.fromMap(Map<String, dynamic> json) {
    return AggregatorItem(
        date: DateTime.parse(json["date"]),
        value: double.parse(json["value"]),
          eaglesStaked: (json["eaglesStaked"]),
          aniasStaked: (json["aniasStaked"])
        );
  }
}

class DataItem {
  String address;
  double value;

  DataItem({required this.address, required this.value});

  factory DataItem.fromMap(Map<dynamic, dynamic> json) {
    // print(json);
    double valu = 0;
    try {
      dynamic ite_repl = json["value"];
      try {
        valu = double.parse(ite_repl);
      } on Error catch(_, e) {
        valu = ite_repl;
      }
    } on Exception catch (_, e) {
      print(json["address"] + ", " + json["value"]);
    }

    return DataItem(address: json["address"], value: valu);
  }
}