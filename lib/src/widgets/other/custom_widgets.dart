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