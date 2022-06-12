import 'package:waves_spy/src/models/chart_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<ChartItem>> getPuzzleEarnings() async{
  const reqStr = "https://script.google.com/macros/s/AKfycbzPF4gGSCKDedr_WVB9xGGG8V-rkYtEyU87CtZr8TriBTd_JQhoi61j8uyh_6_k-kI/exec";
  var resp = await http.get(Uri.parse(reqStr));
  // print(resp);
  List<ChartItem> result = List.empty(growable: true);
  if (resp.statusCode == 200) {
    final json = jsonDecode(resp.body);
    result = json.map<ChartItem>((js) => ChartItem.fromMap(js)).toList();
  } else {
    print("Some error: " + resp.body);
  }
  return result;
}

Future<List<ChartItem>> getEagleEarnings() async{
  const reqStr = "https://script.google.com/macros/s/AKfycbystU3sYJ0QpFdfXwtUMbPoHDxvuXGJB580A0-zTD9Vc90lsPdDx8-mtIyUh7MYDNfU/exec";
  var resp = await http.get(Uri.parse(reqStr));
  // print(resp);
  List<ChartItem> result = List.empty(growable: true);
  if (resp.statusCode == 200) {
    final json = jsonDecode(resp.body);
    result = json.map<ChartItem>((js) => ChartItem.fromMap(js)).toList();
  } else {
    print("Some error: " + resp.body);
  }
  return result;
}