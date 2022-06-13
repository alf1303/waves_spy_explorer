import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/stats_item.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/stats_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/other/custom_widgets.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

class DucksStatsView extends StatelessWidget {
  const DucksStatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _trProvider = TransactionProvider();
    final _filterProvider = FilterProvider();
    final fontSize = getFontSize(context);
    return Container(
      child: Consumer<StatsProvider>(
        builder: (context, model, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      LabeledTextNoScroll("addr: ", "${_trProvider.curAddr}, ", getAddrName(_trProvider.curAddr)),
                      LabeledTextNoScroll("from: ", "${getFormattedDate(_filterProvider.actualFrom)}, "),
                      LabeledTextNoScroll("to: ", "${getFormattedDate(_filterProvider.actualTo)}, "),
                    ],
                  )),
              const Padding(
                padding: EdgeInsets.all(4.0),
                child: Divider(height: 3, color: Colors.blueGrey,),
              ),
              Expanded(child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                          style: const TextStyle(fontSize: 16, height: 1.3),
                          children: [
                          LblGroup(label: "address", val: _trProvider.curAddr, newLine: true),
                          LblGroup(label: "freeDucks", val: model.freeDucksCount.toString(), newLine: true),
                          LblGroup(label: "stakedDucks", val: model.stakedDucksCount.toString(), newLine: true),
                        ]
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Divider(height: 3, color: Colors.blueGrey,),
                    ),
                    Text("Common stats: ", style: TextStyle(fontSize: fontSize),),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: fontSize, height: 1.3),
                        children: getBaseStats()
                      ),
                    ),
                    const Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Divider(height: 3, color: Colors.blueGrey,),
                    ),
                    Text("Rebirth results: ", style: TextStyle(fontSize: fontSize)),
                    RichText(
                      text: TextSpan(
                          style: TextStyle(fontSize: fontSize, height: 1.3),
                          children: getRebirthStats()
                      ),
                    ),
                  ],
                ),
              ),)
            ],
          );
        },
      ),
    );
  }

  List<TextSpan> getBaseStats() {
    final statsProvider = StatsProvider();
    List<TextSpan> res = List.empty(growable: true);
    statsProvider.duckStatsItems.forEach((String key, StatsItem value) {
      res.add(LblGroup(label: key, val: "${value.count},  spent ${(value.amount/pow(10, 8)).toStringAsFixed(3)} Egg", newLine: true));
    });
    return res;
  }

  List<TextSpan> getRebirthStats() {
    final statsProvider = StatsProvider();
    List<TextSpan> res = List.empty(growable: true);
    statsProvider.rebirthResults.forEach((key, value) {
      res.add(LblGroup(label: key, val: "$value", newLine: true));
    });
    return res;
  }
}
