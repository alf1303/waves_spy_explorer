import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UtxProvider extends ChangeNotifier {
  static final UtxProvider _instance = UtxProvider._internal();
  bool isLoading = false;
  List<dynamic> frames = List.empty(growable: true);
  int index = 0;
  double fromTime = 1703542394863;
  List<dynamic> current = List.empty(growable: true);

  factory UtxProvider() {
    return _instance;
  }

  setTs(String tss) {
    fromTime = double.parse(tss);
  }

  nextFrame() {
    // print(frames.length);
    if (frames.length > (index + 1)) {
      index = index + 1;
      current = frames[index]["data"];
      // print(current);
      notifyAll();
    }
  }

  prevFrame() {
    if (0 <= (index - 1)) {
      index = index - 1;
      current = frames[index]["data"];
      notifyAll();
    }
  }

  UtxProvider._internal();

  Future<void> getFrames() async {
    isLoading = true;
    notifyAll();
    try {
      final String url = 'https://stage.wavescup.world/getutx'; // Replace with your API endpoint
      try {
        print(fromTime);
        final http.Response response = await http.post( Uri.parse(url), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Add additional headers if needed
        }, body: jsonEncode({"ts": (fromTime/1000).toInt()*1000}));

        if (response.statusCode == 200) {
          var resp = jsonDecode(response.body)["message"];
          frames = resp;
          if (frames.isNotEmpty) {
            // print(frames[0]);
            index = 0;
            current = frames[index]["data"];
            notifyAll();
          }
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
