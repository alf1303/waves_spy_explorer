import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

class StatsView extends StatelessWidget {
  const StatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _trProvider = TransactionProvider();
    return Container(
      child: Consumer<FilterProvider>(
        builder: (context, model, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      LabeledText("summ: ", "${model.sumacum.toStringAsFixed(5)}, "),
                      LabeledText("asset: ", "${model.assetName}, "),
                      LabeledText("from: ", "${model.actualFrom.toString()}, "),
                      LabeledText("to: ", "${model.actualTo.toString()}, "),
                      LabeledText("addr: ", "${_trProvider.curAddr}, ", "${getAddrName(_trProvider.curAddr)}"),
                      LabeledText("direction: ", "${model.direction.toUpperCase()}")
                    ],
                  )),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: getList(model.finalList, model.assetName),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

List<Widget> getList(Map<String, double> map, String assName) {
  List<Widget> list = List.empty(growable: true);
  var sortedKeys = map.keys.toList(growable:false)
    ..sort((k1, k2) => map[k2]!.compareTo(map[k1]!));
  final sortedMap =  LinkedHashMap
      .fromIterable(sortedKeys, key: (k) => k, value: (k) => map[k]);
  sortedMap.forEach((key, value) {
    final ele = ResultWidget(key, value!, assName);
    list.add(ele);
  });
  return list;
}

Widget ResultWidget(String key, double value, String assName) {
  String val = key;
  bool hidden = true;
  return Container(
    padding: const EdgeInsets.all(5),
    margin: const EdgeInsets.all(2),
    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
    child: Row(children: [
      StatefulBuilder(
          builder: (context, setStat) {
            val = hidden ? key.replaceRange(2, key.length - 2, "." * (key.length - 4)) : key;
            return Row(
              children: [
                SizedBox(width: 350, child: SelectableText(val)),
                GestureDetector(
                    onTap: () {
                      setStat(() => hidden = !hidden);
                    },
                  child: Container(
                    margin: const EdgeInsets.only(right: 15),
                    color: Colors.cyan.shade900, child: const Text("         "),),
                ),
              ],
            );
          }),
      SelectableText("${value.toStringAsFixed(5)} $assName")
    ],),
  );
}
