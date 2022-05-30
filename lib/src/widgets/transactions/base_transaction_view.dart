import 'package:flutter/material.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/data/data_view.dart';
import 'package:waves_spy/src/widgets/transactions/simple_transaction_view.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

class BaseTransactionView extends StatelessWidget {
  const BaseTransactionView({Key? key, required this.td}) : super(key: key);
  final dynamic td;

  getInvokes() {
    final _transactionProvider = TransactionProvider();
    List<dynamic> invs = List.empty(growable: true);
    // print(td);
    if(td["type"] == 16) {
      final List<dynamic> invokes = td["stateChanges"]["invokes"];
      // print("All invokes: ${invokes.length}, ${td["id"]}");
      if(invokes.isNotEmpty) {
        recurInv(_transactionProvider.curAddr, invokes, invs);
      }
    }
    return invs;
  }

  recurInv(String addr, List<dynamic> invokes, List<dynamic> result) {
    if (invokes.isNotEmpty) {
      for(var ele in invokes) {
        if(addr == ele["dApp"]) {
          result.add(ele);
        }
        recurInv(addr, ele["stateChanges"]["invokes"], result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> invokes = getInvokes();
    // print("Internal invokes: ${invokes.length}");
    // print(td["id"]);
    return invokes.isEmpty ? SimpleTransView(td: td) : InvokeView(td: td, invokes: invokes,);
  }
}

class InvokeView extends StatelessWidget {
  const InvokeView({Key? key, required this.td, required this.invokes}) : super(key: key);
  final dynamic td;
  final List<dynamic> invokes;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Column(children: [
        ListView.builder(
          shrinkWrap: true,
            itemCount: invokes.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  InvokeItem(invokes[index]),
                  const Divider()
                ],
              );
            }),
        SimpleTransView(td: td)
      ],)
    );
  }
}

Widget InvokeItem(dynamic inv) {
  return Container(
    child: Row(children: [
      SizedBox(width: 350, child: LabeledText(label: "invoke: ", value: "${inv["call"]["function"]}()", name: ""),),
      SizedBox(width: 400, child: LabeledText(label: "", value: "${inv["dApp"]}", name: ""),),
      SizedBox(width: 400, child: Column(
        children: [
          Transfers(inv),
          Payments(inv)
        ],
      ),),
      // SizedBox(child: Payments(inv),)
    ],),
  );
}

Widget Transfers(dynamic inv) {
  Map<String, double> transfersDict = {};
  for (var ele in inv["stateChanges"]["transfers"]) {
    double amount = ele["amount"] ?? 0;
    final assetId = ele["asset"] ?? "WAVES";
    final addr = ele["address"];
    transfersDict["$addr|||$assetId"] = amount;
  }
  List<Widget> payList = transfersDict.entries.map((e) => assetBuilder(e.key.split("|||")[1], e.value, false, " ", "out", )).toList();
  return OutWidget(payList: payList);
}

Widget Payments(dynamic inv) {
  Map<String, double> payDict = {};
  for (var ele in inv["payment"]) {
    final assetId = ele["assetId"] ?? "WAVES";
    payDict[assetId] = ele["amount"];
  }
  List<Widget> payList = payDict.entries.map((e) => assetBuilder(e.key, e.value, false, " ", "in")).toList();
  return InWidget(income: payList);
}

