import 'package:flutter/material.dart';
import 'package:waves_spy/src/helpers/helpers.dart';

TextSpan  LblGroup({required String label, required String val, String? tab, bool? newLine}) {
  String t = tab ?? "";
  String end = newLine == null ? "" : "\n";
  final fontSize = getLastFontSize();
  return val.isEmpty ? const TextSpan() : TextSpan(
      children: [
        TextSpan(
            style: TextStyle(color: Colors.grey, fontSize: fontSize),
            text: "$t$label: "
        ),
        TextSpan(
            style: TextStyle(color: Colors.white, fontSize: fontSize),
            text: "$val, $end"
        )
      ]
  );
}

class MyToolTip extends StatelessWidget {
  const MyToolTip({Key? key, this.message, required this.child}) : super(key: key);
  final Widget child;
  final String? message;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(10)),
      textStyle: TextStyle(fontSize: 14),
      child: child,
    );
  }
}

class MyDialog extends StatelessWidget {
  MyDialog({Key? key, required this.child, required this.iconSize}) : super(key: key);
  final iconSize;
  Widget child;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(

      actions: [
        OutlinedButton(onPressed: () {Navigator.pop(context);}, child: Text("Close", style: TextStyle(fontSize: iconSize*0.7),),)
      ],
      content: child,
    );
  }
}

