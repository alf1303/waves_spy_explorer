import 'package:flutter/material.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

class DataView extends StatelessWidget {
  const DataView({Key? key, required this.data}) : super(key: key);

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final isNarr = isNarrow(context);
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
              // child: SelectableText("KEY: ${data["key"]}")
            child: SelectableText.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Key: ",
                    style: TextStyle(fontSize: fontSize, color: Colors.white60)
                  ),
                  TextSpan(
                    text: data["key"],
                    style: TextStyle(fontSize: fontSize, color: Colors.white)
                  )
                ]
              ),
            ),
          ),
          !isNarr ? Divider() : Container(),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText.rich(
                 TextSpan(
                    children: [
                      TextSpan(
                          text: "Value: ",
                          style: TextStyle(fontSize: fontSize, color: Colors.white60)
                      ),
                      TextSpan(
                          text: data["value"].toString(),
                          style: TextStyle(fontSize: fontSize, color: Colors.white)
                      )
                    ]
                ),
              )
          )
        ],
      )
    );
  }
}


