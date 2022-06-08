import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:waves_spy/src/helpers/firebase_analytics_service.dart';
import 'firebase_options.dart';
import 'package:get_it/get_it.dart';

import 'src/app.dart';

GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  getIt.registerLazySingleton(() => FirebaseAnalyticsService());
  String myUrl = Uri.base.toString();
  String? addre = Uri.base.queryParameters["address"]; //get parameter with attribute "para1"
  runApp(MyApp(address: addre));
}
