class ChartItem {
  DateTime date;
  double value;

  ChartItem({required this.date, required this.value});

  factory ChartItem.fromMap(Map<String, dynamic> json) {
    return ChartItem(date: DateTime.parse(json["date"]), value: double.parse(json["value"]));
  }
}