import 'package:waves_spy/src/models/chart_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:waves_spy/src/providers/puzzle_provider.dart';
final puzzleProvider = PuzzleProvider();

Future<Map<String, List<dynamic>>> getBurnMachine() async{
  final puzzleProvider = PuzzleProvider();
  const reqDaily = "https://script.google.com/macros/s/AKfycbz3e9UcAzJPk-TZgfkptIW_bhqvUKiqKPeksJuMtbdLbYxOokkEHkkXSSglimJjdUQ/exec";
  const reqDapp = "https://script.google.com/macros/s/AKfycbxcguqxGA9Az1wEvahT1NXDqCL-VfIsWVStgooNWDL5fu_3WMyvzMnlBhvVdnkcvmw/exec";
  const reqUsers = "https://script.google.com/macros/s/AKfycbz24uBx0AuBStNXBnGvowND8mS1SKcDGwoF3S1Fq3sesaQJwFc7uV3rmumI7y-_N6k/exec";
  // print(resp);
  List<ChartItem> dailyResult = List.empty(growable: true);
  List<DataItem> dappResult = List.empty(growable: true);
  List<DataItem> userResult = List.empty(growable: true);
print("In");
  var respDaily = await http.get(Uri.parse(reqDaily));
  if (respDaily.statusCode == 200) {
    final json = jsonDecode(respDaily.body);
    // print(json);
    dailyResult = json.map<ChartItem>((js) => ChartItem.fromMap(js)).toList();
  } else {
    print("Some error loading daily burns: " + respDaily.body);
  }
  dailyResult.removeLast();
print("Daily made");
  var respDapp = await http.get(Uri.parse(reqDapp));
  if (respDapp.statusCode == 200) {
    final json = jsonDecode(respDapp.body);
    dappResult = json.map<DataItem>((js) => DataItem.fromMap(js)).toList();
  } else {
    print("Some error loading daily burns: " + respDapp.body);
  }
print("dApp made");
  var respUser = await http.get(Uri.parse(reqUsers));
  if (respUser.statusCode == 200) {
    final json = jsonDecode(respUser.body);
    // print(json);
    userResult = json.map<DataItem>((js) => DataItem.fromMap(js)).toList();
  } else {
    print("Some error loading daily burns: " + respUser.body);
  }
  print("User made");
  puzzleProvider.setDappList(dappResult);
  puzzleProvider.setUserList(userResult);
  Map<String, List<dynamic>> res = {};
  res["daily"] = dailyResult;
  res["dapp"] = dappResult;
  res["user"] = userResult;
  return res;
}

Future<List<ChartItem>> getPuzzleEarnings() async{
  // const reqStr = "https://script.google.com/macros/s/AKfycby9igo7gRssoZXrSgnWw1kphYMHJCS8zmYtlF0aWKqhQ4vYnMG1Mt34WO9kpcqDsQHr/exec";
  const reqStr = "https://script.google.com/macros/s/AKfycbxrK8Deg4k9bu3Qu1qP6-uyHC2AUbg_ZP_RY21vom7UQ09jc1NbYBCagMXNGH2ptf9-/exec";
  var resp = await http.get(Uri.parse(reqStr));
  // print(resp);
  List<ChartItem> result = List.empty(growable: true);
  if (resp.statusCode == 200) {
    final json = jsonDecode(resp.body);
    result = json.map<ChartItem>((js) => ChartItem.fromMap(js)).toList();
  } else {
    print("Some error_1: " + resp.body);
  }
  // result.removeLast();
  return result;
}

Future<List<AggregatorItem>> getEagleEarnings() async{
  final puzzleProvider = PuzzleProvider();
  // const reqStr = "https://script.google.com/macros/s/AKfycbzybJQqxDGSuVg6XaJY6ydLjqH2nkvRIa5OJuuAkqu3M0PjL5B1dyK4S0IV6T7uT7S4/exec";
  const reqStr = "https://script.google.com/macros/s/AKfycbxrK8Deg4k9bu3Qu1qP6-uyHC2AUbg_ZP_RY21vom7UQ09jc1NbYBCagMXNGH2ptf9-/exec";
  var resp = await http.get(Uri.parse(reqStr));
  // print(resp);
  List<AggregatorItem> result = List.empty(growable: true);
  if (resp.statusCode == 200) {
    final json = jsonDecode(resp.body);
    // print(json);
    result = json.map<AggregatorItem>((js) => AggregatorItem.fromMap(js)).toList();
    dynamic semiLastItem = (json[json.length-1]);
    print(semiLastItem);
    puzzleProvider.lastEaglesStaked = semiLastItem["eaglesStaked"];
    puzzleProvider.lastAniasStaked = semiLastItem["aniasStaked"];
  } else {
    print("Some error_2: " + resp.body);
  }
  // result.removeLast();
  return result;
}

Future<dynamic> loadChartsData(String target) async {
  if(puzzleProvider.aggregatorData.isEmpty) {
    puzzleProvider.aggregatorData = await getEagleEarnings();
    print("Eagle got");
  }
  if(puzzleProvider.puzzleData.isEmpty) {
    puzzleProvider.puzzleData = await getPuzzleEarnings();
    print("Puzzle got");
  }
  // if(puzzleProvider.burnData.isEmpty) {
  //   puzzleProvider.burnData = await getBurnMachine();
  //   print("Burn got");
  // }
  switch(target) {
    case "puzzle":
      return puzzleProvider.puzzleData;
    case "burn":
      return puzzleProvider.burnData;
    case "aggregator":
      return puzzleProvider.aggregatorData;
    default:
      return puzzleProvider.aggregatorData;
  }
}