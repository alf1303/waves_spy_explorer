import 'dart:convert';
import 'dart:js';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/firebase_analytics_service.dart';
import 'firebase_options.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'src/app.dart';

GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const req = "https://script.google.com/macros/s/AKfycbyWkPTqRwfGtPPXRGkKk_bHQ2ann3Y50iIAMjfRpQe9LusZ6FsKXKXb6O9y_aik34g/exec";
  var resp = await http.get(Uri.parse(req));
  if(resp.statusCode == 200) {
    final json = jsonDecode(resp.body);
    for(var el in json) {
      dAppsDict[el['address']] = el['name'];
    }
  }
  // print(publicAddr.length);
  getIt.registerLazySingleton(() => FirebaseAnalyticsService());
  String myUrl = Uri.base.toString();
  String? addre = Uri.base.queryParameters["address"]; //get parameter with attribute "para1"
  runApp(MyApp(address: addre));
}
