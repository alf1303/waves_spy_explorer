import 'package:flutter/material.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

class DataView extends StatelessWidget {
  const DataView({Key? key, required this.data}) : super(key: key);

  final dynamic data;

  @override
  Widget build(BuildContext context) {
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
                  const TextSpan(
                    text: "Key: ",
                    style: TextStyle(color: Colors.white60)
                  ),
                  TextSpan(
                    text: data["key"],
                    style: const TextStyle(color: Colors.white)
                  )
                ]
              ),
            ),
          ),
          Divider(),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText.rich(
                 TextSpan(
                    children: [
                      const TextSpan(
                          text: "Value: ",
                          style: TextStyle(color: Colors.white60)
                      ),
                      TextSpan(
                          text: data["value"].toString(),
                          style: const TextStyle(color: Colors.white)
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


