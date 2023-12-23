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
      textStyle: TextStyle(fontSize: 16),
      child: child,
    );
  }
}

class MyDialog extends StatelessWidget {
  MyDialog({Key? key, required this.child, required this.iconSize, this.title}) : super(key: key);
  final iconSize;
  Widget child;
  final title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title == null ? title : Text(title),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(iconSize*0.5))),
      actions: [
        OutlinedButton(onPressed: () {Navigator.pop(context);}, child: Text("Close", style: TextStyle(fontSize: iconSize*0.7),),)
      ],
      content: child,
    );
  }
}

