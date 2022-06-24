import 'package:waves_spy/src/models/chart_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, List<dynamic>>> getBurnMachine() async{
  const reqDaily = "https://script.google.com/macros/s/AKfycbz3e9UcAzJPk-TZgfkptIW_bhqvUKiqKPeksJuMtbdLbYxOokkEHkkXSSglimJjdUQ/exec";
  const reqDapp = "https://script.google.com/macros/s/AKfycbxcguqxGA9Az1wEvahT1NXDqCL-VfIsWVStgooNWDL5fu_3WMyvzMnlBhvVdnkcvmw/exec";
  const reqUsers = "https://script.google.com/macros/s/AKfycbz24uBx0AuBStNXBnGvowND8mS1SKcDGwoF3S1Fq3sesaQJwFc7uV3rmumI7y-_N6k/exec";
  // print(resp);
  List<ChartItem> dailyResult = List.empty(growable: true);
  List<DataItem> dappResult = List.empty(growable: true);
  List<DataItem> userResult = List.empty(growable: true);

  var respDaily = await http.get(Uri.parse(reqDaily));
  if (respDaily.statusCode == 200) {
    final json = jsonDecode(respDaily.body);
    print(json);
    dailyResult = json.map<ChartItem>((js) => ChartItem.fromMap(js)).toList();
  } else {
    print("Some error loading daily burns: " + respDaily.body);
  }
  dailyResult.removeLast();

  var respDapp = await http.get(Uri.parse(reqDapp));
  if (respDapp.statusCode == 200) {
    final json = jsonDecode(respDapp.body);
    dappResult = json.map<DataItem>((js) => DataItem.fromMap(js)).toList();
  } else {
    print("Some error loading daily burns: " + respDapp.body);
  }

  var respUser = await http.get(Uri.parse(reqUsers));
  if (respUser.statusCode == 200) {
    final json = jsonDecode(respUser.body);
    userResult = json.map<DataItem>((js) => DataItem.fromMap(js)).toList();
  } else {
    print("Some error loading daily burns: " + respUser.body);
  }
  Map<String, List<dynamic>> res = {};
  res["daily"] = dailyResult;
  res["dapp"] = dappResult;
  res["user"] = userResult;
  return res;
}

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
  result.removeLast();
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
  result.removeLast();
  return result;
}