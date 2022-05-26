import 'package:flutter/material.dart';

import 'src/app.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // setPathUrlStrategy();
  String myUrl = Uri.base.toString();
  String? addre = Uri.base.queryParameters["address"]; //get parameter with attribute "para1"
  runApp(MyApp(address: addre));
}
