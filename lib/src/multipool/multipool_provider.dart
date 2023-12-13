import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart' as http;

class MultipoolProvider extends ChangeNotifier {
  static final MultipoolProvider _instance = MultipoolProvider._internal();

  factory MultipoolProvider() {
    return _instance;
  }

  MultipoolProvider._internal();
  final assets = ["usdt", "puzzle", "pluto", "waves", "surf", "usdt_wxg"];

  bool isLoading = false;

  Map<String, dynamic> defItem = {"assetId": "usdt", "amount": 1000, "weight": 5000,
  "amountController": TextEditingController(text: "1000"),
  "weightController": TextEditingController(text: "5000")};

  Map<String, dynamic> result = {};

  int stepsAmount = 5;
  int fee = 0;
  bool use_arb = true;
  final df = TextEditingController(text: "1000");
  List<Map<String, dynamic>> initAssets = [
    {"assetId": "usdt", "amount": 4000, "weight": 4000,
      "amountController": TextEditingController(text: "4000"),
      "weightController": TextEditingController(text: "4000")},
    {"assetId": "puzzle", "amount": 3000, "weight": 3000,
      "amountController": TextEditingController(text: "3000"),
      "weightController": TextEditingController(text: "3000")},
    {"assetId": "pluto", "amount": 3000, "weight": 3000,
      "amountController": TextEditingController(text: "3000"),
      "weightController": TextEditingController(text: "3000")}
  ];
  List<Map<String, dynamic>> rebalanceAssets = [
    {"assetId": "usdt", "amount": 0, "weight": 4000,
      "amountController": TextEditingController(text: "0"),
      "weightController": TextEditingController(text: "4000")},
    {"assetId": "puzzle", "amount": 0, "weight": 4000,
      "amountController": TextEditingController(text: "0"),
      "weightController": TextEditingController(text: "4000")},
    {"assetId": "pluto", "amount": 0, "weight": 2000,
      "amountController": TextEditingController(text: "0"),
      "weightController": TextEditingController(text: "2000")},
  ];

  setAsset(String assetId, String type, int index) {
    List<Map<String, dynamic>> lst = type == "init" ? initAssets : rebalanceAssets;
    Map<String, dynamic> item = lst[index];
    item["assetId"] = assetId;
    notifyAll();
  }

  setStepsAmount(String amount) {
    stepsAmount = int.parse(amount);
  }

  setFee(String feee) {
    fee = int.parse(feee);
  }

  setUseArb(bool? useArb) {
    use_arb = useArb!;
    notifyAll();
  }

  setAmount(String assetId, String amount, String type) {
    List<Map<String, dynamic>> lst = type == "init" ? initAssets : rebalanceAssets;
    Map<String, dynamic> item = lst.firstWhere((element) => element["assetId"] == assetId);
    item["amount"] = int.parse(amount);
    // print("--> amount: " + item["amount"].toString());
  }

  setWeight(String assetId, String weight, String type) {
    List<Map<String, dynamic>> lst = type == "init" ? initAssets : rebalanceAssets;
    Map<String, dynamic> item = lst.firstWhere((element) => element["assetId"] == assetId);
    item["weight"] = int.parse(weight);
    // print("--> weight: " + item["weight"].toString());
  }

  addItem(String type) {
    List<Map<String, dynamic>> lst = type == "init" ? initAssets : rebalanceAssets;
    lst.add(defItem);
    notifyAll();
  }

  removeItem(String type, String assetId, int index) {
    List<Map<String, dynamic>> lst = type == "init" ? initAssets : rebalanceAssets;
    // lst.removeWhere((element) => element["assetId"] == assetId);
    lst.removeAt(index);
    notifyAll();
  }

  Future<void> makeRequest() async {
    isLoading = true;
    notifyAll();
    try {
      final String url = 'https://stage.wavescup.world/calcrebal'; // Replace with your API endpoint
      Map<String, dynamic> init_data = {};
      Map<String, dynamic> rebalance_data = {};
      for (Map<String, dynamic> item in initAssets) {
        init_data[item["assetId"]] = {"amount": item["amount"], "weight": item["weight"]};
      }
      for (Map<String, dynamic> item in rebalanceAssets) {
        rebalance_data[item["assetId"]] = {"amount": item["amount"], "weight": item["weight"]};
      }
      // Replace the map with your request payload
      Map<String, dynamic> requestBody = {
        'stepsAmount': stepsAmount,
        'fee': fee,
        'use_arb': use_arb,
        'init_data_js': init_data,
        'rebalance_data_js': rebalance_data
      };
      // print("use_arb ---> $use_arb");
      try {
        final http.Response response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            // Add additional headers if needed
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          // Handle the successful response
          // print('Response: ${response.body}');
          result = jsonDecode(response.body)["message"];
          // print(result);
          notifyAll();
          // print(result);
        } else {
          // Handle error
          print('Error: ${response.statusCode}');
        }
      } catch (error) {
        // Handle network and other errors
        print('Error: $error');
      }
    } finally {
      isLoading = false;
      notifyAll();
    }
  }

  notifyAll() {
    notifyListeners();
  }
}