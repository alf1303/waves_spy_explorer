import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/providers/progress_bars_provider.dart';

class MyProgressBar extends StatelessWidget {
  const MyProgressBar({Key? key, required this.label}) : super(key: key);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(builder: (context, model, child) {
      return Visibility(
        visible: model.getBool(label),
          child: LinearProgressIndicator()
      );
    });
  }
}
