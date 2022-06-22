import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/farmStakingItem.dart';
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
    final height = fontSize/13;
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
                          style: TextStyle(fontSize: fontSize, height: height),
                          children: [
                          LblGroup(label: "address", val: _trProvider.curAddr, newLine: true),
                          LblGroup(label: "freeDucks", val: model.freeDucksCount.toString(), newLine: true),
                          LblGroup(label: "stakedDucks", val: model.stakedDucksCount.toString(), newLine: true),
                            LblGroup(label: "ducks in Wars", val: model.jediDucksCount.toString(), newLine: true),
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
                        style: TextStyle(fontSize: fontSize, height: height),
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
                          style: TextStyle(fontSize: fontSize, height: height),
                          children: getRebirthStats()
                      ),
                    ),
                    const Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Divider(height: 3, color: Colors.blueGrey,),
                    ),
                    Text("Farm Staking stats: ", style: TextStyle(fontSize: fontSize)),
                    FutureBuilder<List<FarmStakingItem>?>(
                      future: model.getFarmStakingData(_trProvider.curAddr),
                        builder: (context, snapshot) {
                        Widget widget;
                          if(snapshot.hasData) {
                            widget = getStakedItems(snapshot.data!);
                          } else if(snapshot.hasError) {
                            widget = Text("Error while loading");
                          } else {
                            widget = const Center(child: CircularProgressIndicator(),);
                          }
                          return widget;
                        })
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
  
  Widget getStakedItems(List<FarmStakingItem> items) {
    final fontSize = getLastFontSize();
    double tStaked = 0, tClaimed = 0, tAvailable = 0;
    TextStyle lblStyle = TextStyle(fontSize: fontSize, color: Colors.grey);
    TextStyle valueStyle = TextStyle(fontSize: fontSize, color: Colors.white);
    List<TextSpan> list = List.empty(growable: true);
    int longestFarmName = 0;
    for (FarmStakingItem el in items) {
      if(el.farmName.length > longestFarmName) {
        longestFarmName = el.farmName.length;
      }
    }
    print("Longest: $longestFarmName");
    for (FarmStakingItem el in items) {
      // print("${el.farmName}");
      tStaked += el.staked;
      tAvailable += el.available;
      tClaimed += el.claimed;
      final spaces = " "*(longestFarmName - el.farmName.length + 2);
      print("longest: ${longestFarmName}, spaces: ${spaces.length}, farmLength: ${el.farmName.length}");
      TextSpan span = TextSpan(
        children: [
          TextSpan(text: "${el.farmName}: $spaces", style: valueStyle),
          stakedInfoView("Staked", el.staked, lblStyle, valueStyle),
          stakedInfoView("Claimed", el.claimed, lblStyle, valueStyle),
          stakedInfoView("Available", el.available, lblStyle, valueStyle),
          TextSpan(text: "\n")
        ]
      );
      list.add(span);
    }
    TextSpan total = TextSpan(
      children: [
        stakedInfoView("Total Staked", tStaked, lblStyle, valueStyle),
        stakedInfoView("Total Claimed", tClaimed, lblStyle, valueStyle),
        stakedInfoView("Total Available", tAvailable, lblStyle, valueStyle),
      ]
    );
    list.add(total);
    final result = SelectableText.rich(
        TextSpan(
            children: list
        ),
      style: TextStyle(height: fontSize/10),
    );
    return result;
  }

  TextSpan stakedInfoView(String label, double value, TextStyle lblStyle, TextStyle valueStyle) {
    return TextSpan(
        children: [
          TextSpan(text: "$label: ", style: lblStyle),
          TextSpan(text: "${(value/100000000).toStringAsFixed(8)}, ", style: valueStyle),
        ]
    );
  }
}


