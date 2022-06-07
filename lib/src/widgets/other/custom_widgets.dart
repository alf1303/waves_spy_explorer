import 'package:flutter/material.dart';

TextSpan  LblGroup({required String label, required String val, String? tab, bool? newLine}) {
  String t = tab ?? "";
  String end = newLine == null ? "" : "\n";
  return val.isEmpty ? const TextSpan() : TextSpan(
      children: [
        TextSpan(
            style: const TextStyle(color: Colors.grey),
            text: "$t$label: "
        ),
        TextSpan(
            style: const TextStyle(color: Colors.white),
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
