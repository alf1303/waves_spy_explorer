import 'dart:math';

import 'package:flutter/material.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:intl/intl.dart';
import 'package:waves_spy/src/models/asset.dart';
import 'package:waves_spy/src/providers/transaction_details_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/styles.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

class SimpleTransView extends StatelessWidget {
  const SimpleTransView({Key? key, required this.td}) : super(key: key);
  final dynamic td;

  void showDetails() {
    final _trDetailsProvider = TransactionDetailsProvider();
    _trDetailsProvider.setTransaction(td);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy  kk:mm:ss.SSS').format(timestampToDate(td["timestamp"]));
    Color color = Colors.white;
    color = getColorByType(td["type"]);
    final _transactionProvider = TransactionProvider();
    final type = td["type"];
    bool exop = false;
    Widget header = Text("");

    Map<String, dynamic> p = parseTransactionType(td);
    exop = p['exchPriceAsset'] == " " ? false : true;
    Map<String, double> payment = p['payment'];
    Map<String, double> transfers = p["transfers"];
    switch (p['header']) {
      case "invoke":
        header = invokeHeader(p);
        break;
      case "transfer":
        header = transferHeader(p);
        break;
      case "massTransfer":
        header = massTransferHeader(p);
        break;
      case "burn":
        header = burnHeader(p);
        break;
      case "exchange":
        header = exchangeHeader(p);
        break;
    // TODO implement:
      case "setScript":
        break;
      case "data":
        break;
      case "alias":
        break;
      case "issue":
        break;
      case "reissue":
        break;
      case "setAssetScript":
        break;
      case "updateAssetInfo":
        break;
      case "lease":
        break;
      case "leaseCancel":
        break;
      case "setSponsorship":
        break;
    }
    String dApp = "";
    if (td.containsKey("dApp")) {dApp = td["dApp"];}
    String out = _transactionProvider.curAddr != dApp ? "out" : "in";
    String inn = _transactionProvider.curAddr != dApp ? "in" : "out";
    List<Widget> payList = payment.entries.map((e) => assetBuilder(e.key, e.value, exop, p["exchPriceAsset"], out)).toList();
    List<Widget> inList = transfers.entries.map((e) => assetBuilder(e.key, e.value, exop, p["exchPriceAsset"], inn)).toList();

    return InkWell(
      hoverColor: hoverColor,
      onTap: showDetails,
      child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Row(
            children: [
              SizedBox(width: 200, child: LabeledText("", formattedDate, "", color)),
              SizedBox(width: 150, child: LabeledText("", getTypeName(td["type"]), "${td["type"]}", color), ),
              Expanded(
                child: SizedBox(width: 350, child:
                td["type"] == 16 ? invokeHeader(p) :
                  td["type"] == 4 ? transferHeader(p) :
                      td["type"] == 11 ? massTransferHeader(p) :
                          Container(),
                ),
              ),
              Expanded(
                child: SizedBox(child: _transactionProvider.curAddr != dApp ?
                Row(
                  children: [
                    payList.isNotEmpty ? Expanded(child: OutWidget(payList: payList,)) : Container(),
                    transfers.isNotEmpty ? Expanded(child: InWidget(income: inList,)) : Container()
                  ],
                ) :
                Row(
                  children: [
                    payList.isNotEmpty ? Expanded(child: InWidget(income: payList,)) : Container(),
                    transfers.isNotEmpty ? Expanded(child: OutWidget(payList: inList,)) : Container()
                  ],
                ),),
              ),
              // LabeledText("id: ", td["id"], "", color),
            ],)
      ),
    );
  }

  Color getColorByType(type) {
    switch(type) {
      case 4:
        return transferColor;
      case 6:
        return burnColor;
      case 7:
        return exchangeColor;
      case 11:
        return  massTransferColor;
      case 16:
        return invokeColor;
      default:
        return Colors.white;
    }
  }
}


Widget invokeHeader(Map<String, dynamic> p) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        SizedBox(width: 150, child: LabeledText("", p["function"], "", invokeColor)),
        Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: LabeledText("sender:", p["sender"], "", invokeColor))),
      ],
    ),
  );
}

Widget exchangeHeader(Map<String, dynamic> p) {
  return Row(
    children: [
      SizedBox(width: 600,
          child: Row(
            children: [
              LabeledText("sellOrder:", "", "", exchangeColor),
              Expanded(child: assetBuilder(p['amountAsset'], p['sellOrder'], false, p['amountAsset'], "out"))
            ],
          )
      ),
      SizedBox(width: 300,
          child: Row(
            children: [
              LabeledText("buyOrder:", "", "", exchangeColor),
              Expanded(child: assetBuilder(p['amountAsset'], p['buyOrder'], false, p['amountAsset'], "in"))
            ],
          )
      ),

    ],
  );
}

Widget transferHeader(Map<String, dynamic> p) {
  String suffix = "";
  if(p["direction"] == "IN") {
    suffix = "from: ";
  } else {
    suffix = "to: ";
  }
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        SizedBox(width: 150, child: Container(),),
        Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: LabeledText(suffix, p["anotherAddr"], "", transferColor))),
      ],
    ),
  );
}

Widget massTransferHeader(Map<String, dynamic> p) {
  final _transactionProvider = TransactionProvider();
  return SingleChildScrollView(child: SizedBox(width: 740, child: LabeledText("from", p["anotherAddr"], p["name"], massTransferColor),));
}

// TODO
Widget burnHeader(Map<String, dynamic> p) {
  return Container();
}
