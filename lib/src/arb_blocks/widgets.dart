import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/arb_blocks/blocks_provider.dart';
import 'package:waves_spy/src/arb_blocks/utils.dart';
import 'package:waves_spy/src/helpers/helpers.dart';

class ViewBlockWidget extends StatelessWidget {
  const ViewBlockWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<BlocksProvider>(
        builder: (context, model, child) {
          return FutureBuilder<Map<String, dynamic>>(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(child: CircularProgressIndicator());
              }
              if(snapshot.hasData) {
                final data = snapshot.data ?? {};
                final transactions = data["transactions"] ?? [];
                return Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LabeledTextLL("height: ", "${data["height"]}"),
                          LabeledTextLL("generator: ", "${data["generator"]}"),
                          LabeledTextLL("invoke tx count: ", "${data["transactions"].length}")
                        ],
                      ),
                      Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.white70),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text("")),
                                DataColumn(label: Text("TYPE")),
                                DataColumn(label: Text("FUNCTION")),
                                DataColumn(label: Text("ID")),
                                DataColumn(label: Text("DAPP")),
                                DataColumn(label: Text("SENDER")),
                                DataColumn(label: Text("INFO")),
                                DataColumn(label: Text("OPS")),
                              ],
                              dividerThickness: 2,
                              rows:
                                transactions.map<DataRow>((tx) {
                                  return DataRow(cells: [
                                    DataCell(getStatus(tx)),
                                    DataCell(getType(tx)),
                                    DataCell(getFunction(tx)),
                                    DataCell(getId(tx)),
                                    DataCell(getDapp(tx)),
                                    DataCell(getSender(tx)),
                                    DataCell(TxInfo(tx: tx,)),
                                    DataCell(AssetsCell(tx: tx,))
                                  ],  color: getRowColor(tx, targetTx: model.txid));
                                }).toList()
                            ),
                          ),
                        ),

                        // child: ListView.builder(
                        //   shrinkWrap: true,
                        //     itemCount: transactions.length,
                        //     itemBuilder: (context, i) {
                        //       return TxView(tx: transactions[i]);
                        //     }
                        // ),
                      )
                    ],
                  ),
                );
              } else {
                // print(snapshot);
                return Text("Some error or no data");
              }
            },
          );
        }
      )
    );
  }
}

class TxView extends StatelessWidget {
  const TxView({Key? key, required this.tx}) : super(key: key);
  final Map<String, dynamic> tx;

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    print(tx);
    final int type = tx["type"];
    final String function = type == 16 ? tx["call"]["function"] : "<exchange>";
    final String dapp = type == 16 ? tx["dApp"] : "matcher";
    final String sender = tx["sender"];
    final String id = tx["id"];
    final int fee = tx["fee"];
    // final int complexity = type == 16 ? tx["spentComplexity"] : 0;
    final bool success = type == 16 ? tx["applicationStatus"] == "succeeded" : true;
    return Container(
        padding: const EdgeInsets.all(5),
    margin: const EdgeInsets.all(2),
    decoration: BoxDecoration(
    // color: fail ? Colors.white12 : null,
    border: Border.all(color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableText(id, style: TextStyle(fontSize: fontSize),)
      ],
    )
    );
  }
}


Widget LabeledTextLL([String? label, String? value, String? name, Color? colr]) {
  final labl = label ?? "";
  final val = value ?? "";
  final nam = name ?? "";
  final col = colr ?? Colors.white;
  // print("$labl, $val, $nam");
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SelectableText(labl, style: const TextStyle(color: Colors.grey),),
      nam == "" ? const Text("") : SelectableText("($name)", style: TextStyle(color: col)),
      SelectableText("$val ", style: TextStyle(color: col),),
    ],);
}
