import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/addresses_stats_item.dart';
import 'package:waves_spy/src/models/asset.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

class AddressesStatsView extends StatefulWidget {
  const AddressesStatsView({Key? key}) : super(key: key);

  @override
  State<AddressesStatsView> createState() => _AddressesStatsViewState();
}

class _AddressesStatsViewState extends State<AddressesStatsView> {
  bool income = true;
  void sortByIn() {
    final filterProvider = FilterProvider();
    income = true;
    filterProvider.notifyAll();
  }

  void sortByOut() {
    final filterProvider = FilterProvider();
    income = false;
    filterProvider.notifyAll();  }

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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        LabeledTextNoScroll("income: ", "${model.sumacum_in.toStringAsFixed(5)}, "),
                        LabeledTextNoScroll("outcome: ", "${model.sumacum_out.toStringAsFixed(5)}, "),
                        LabeledTextNoScroll("asset: ", "${model.assetName}, "),
                        LabeledTextNoScroll("from: ", "${getFormattedDate(model.actualFrom)}, "),
                        LabeledTextNoScroll("to: ", "${getFormattedDate(model.actualTo)}, "),
                        LabeledTextNoScroll("addr: ", "${_trProvider.curAddr}, ", "${getAddrName(_trProvider.curAddr)}"),
                        LabeledTextNoScroll("direction: ", model.direction.toUpperCase())
                      ],
                    ),
                  )),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 3.0),
                child: Divider(height: 4, color: Colors.blueGrey,),
              ),
              Row(children: [
                const SizedBox(width: 300, child: Center(child: Text("Address")),),
                InkWell(child: const SizedBox(width: 300, child: Center(child: Text("In")),), onTap: sortByIn),
                InkWell(child: const SizedBox(width: 200, child: Center(child: Text("Out")),), onTap: sortByOut,),
                const SizedBox(width: 150, child: Center(child: Text("Address Name")),),
              ],),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 3.0),
                child: Divider(height: 4, color: Colors.blueGrey,),
              ),
              Expanded(
                child: ListView(
                  primary: false,
                  shrinkWrap: true,
                  children: getList(model.finalList, model.assetName, income),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

List<Widget> getList(Map<String, AddressesStatsItem> map, Asset assName, bool income) {
  List<Widget> list = List.empty(growable: true);
  var sortedKeys = map.keys.toList(growable:false)
    ..sort((k1, k2) => income ? map[k2]!.income.compareTo(map[k1]!.income) : map[k2]!.outcome.compareTo(map[k1]!.outcome));
  final sortedMap =  LinkedHashMap
      .fromIterable(sortedKeys, key: (k) => k, value: (k) => map[k]);
  sortedMap.forEach((key, value) {
    final ele = ResultWidget(value, assName.name);
    list.add(ele);
  });
  return list;
}

Widget ResultWidget(AddressesStatsItem? it, String assName) {
  String key = it!.address;
  String val = it.address;
  bool hidden = false;
  // print(val.length);
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
                // SizedBox(width: 350, child: LinkToAddress(val: val, label: val, color: Colors.white,)),
                SizedBox(width: 350, child: LabeledText(label: "view: ", value: val, addrLink: true)),
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
      SizedBox(width: 200, child: SelectableText("${it.income.toStringAsFixed(5)} $assName", style: const TextStyle(color: Colors.green),)),
      SizedBox(width: 250, child: SelectableText("${it.outcome.toStringAsFixed(5)} $assName", style: const TextStyle(color: Colors.redAccent),)),
      SelectableText(getAddrName(val), style: const TextStyle(color: Colors.white60),)
    ],),
  );
}
