import 'dart:math';

import 'package:flutter/material.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:intl/intl.dart';
import 'package:waves_spy/src/models/asset.dart';
import 'package:waves_spy/src/providers/transaction_details_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/styles.dart';

extension TruncateDoubles on double {
  double truncat(int fractionalDigits) => (this * pow(10,
      fractionalDigits)).truncate() / pow(10, fractionalDigits);
}

class TransView extends StatelessWidget {
  const TransView({Key? key, required this.td}) : super(key: key);
  final dynamic td;

  void showDetails() {
    final _trDetailsProvider = TransactionDetailsProvider();
    _trDetailsProvider.setTransaction(td);
    // print("Tap" + td);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy  kk:mm:ss.SSS').format(timestampToDate(td["timestamp"]));
    Color color = Colors.white;
    switch(td["type"]) {
      case 4:
         color = transferColor; break;
      case 6:
         color = burnColor; break;
      case 7:
         color = exchangeColor; break;
      case 11:
         color = massTransferColor; break;
      case 16:
         color = invokeColor; break;
      default:
         color = Colors.white;
    }
    return InkWell(
      onTap: showDetails,
      child: Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Column(
          children: [
          Row(
            children: [
            SizedBox(width: 240, child: LabeledText("type: ", getTypeName(td["type"]), "${td["type"]}", color), ),
            // Container(color: Colors.white, width: 3, height: 10,),
            SizedBox(width: 300, child: LabeledText("date: ", formattedDate, "", color)),
            SizedBox(width: 200, child: LabeledText("height: ", td["height"].toString(), "", color)),
            LabeledText("id: ", td["id"], "", color),
          ],),
            Divider(),
            Details(td: td)
        ],)
      ),
    );
  }
}

class Details extends StatelessWidget {
  final dynamic td;
  const Details({Key? key, this.td}) : super(key: key);
  @override
  Widget build(BuildContext context) {

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
    return  Column(
      children: [
        header,
        Divider(),
        _transactionProvider.curAddr != dApp ?
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
        )
      ],
    );
  }
}

Widget invokeHeader(Map<String, dynamic> p) {
  return Row(
    children: [
      SizedBox(width: 240, child: LabeledText("function:", p["function"], "", invokeColor)),
      SizedBox(width: 500, child: LabeledText("dApp:", p["dApp"], p["dAppName"], invokeColor),),
      SizedBox(child: LabeledText("Sender:", p["sender"], "", invokeColor),),
    ],
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
    suffix = "Received from: ";
  } else {
    suffix = "Sent to: ";
  }
  return Row(
    children: [
      SizedBox(child: LabeledText(suffix, p["anotherAddr"], p["name"], transferColor),),
      // SizedBox(width: 800, child: LabeledText("dApp:", "${p["dApp"]} (${p["dAppName"]})"),),
    ],
  );
}

Widget massTransferHeader(Map<String, dynamic> p) {
  return Row(
    children: [
      SizedBox(child: LabeledText("From", p["anotherAddr"], p["name"], massTransferColor),),
      // SizedBox(width: 800, child: LabeledText("dApp:", "${p["dApp"]} (${p["dAppName"]})"),),
    ],
  );
}

// TODO
Widget burnHeader(Map<String, dynamic> p) {
  return Container();
}

Widget assetBuilder(String id, val, exop, String amountId, String dir) {
  String tmpAss = id + ".|." + amountId;
  return FutureBuilder<List<Asset?>>(
      future: getAssetInfoLabel(tmpAss),
      builder: (context, snapshot) {
        Widget widget;
        if (snapshot.hasData) {
          int decimals = snapshot.data![0]!.decimals;
          double value = val / pow(10, decimals);
          if (exop) {
            int exchDecimals = snapshot.data![1]!.decimals;
            if (id != amountId) {
              value = value / pow(10, exchDecimals);
            }
          }
          widget = Text("${value.truncat(decimals)} ${snapshot.data![0]!.name}", style: TextStyle(color: dir == "in" ? inAssetsColor : outAssetsColor),);
        } else if (snapshot.hasError) {
          print(snapshot.error.toString());
          widget = Text("Error");
        } else {
          widget = Text("loading");
        }
        return widget;
      }
  );
}

class OutWidget extends StatelessWidget {
  const OutWidget({Key? key, required this.payList}) : super(key: key);
  final payList;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Out --> ", style: TextStyle(color: outAssetsColor),),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: payList,),
        ),
      ],
    );
  }
}

class InWidget extends StatelessWidget {
  const InWidget({Key? key, required this.income}) : super(key: key);
  final income;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("In <-- ", style: TextStyle(color: inAssetsColor),),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: income,),
        ),
      ],
    );
  }
}

Widget LabeledText([String? label, String? value, String? name, Color? colr]) {
  final labl = label ?? "";
  final val = value ?? "";
  final nam = name ?? "";
  final col = colr ?? Colors.white;
  // print("$labl, $val, $nam");
  return Row(children: [
    Text(labl, style: const TextStyle(color: Colors.grey),),
    nam == "" ? Text("") : SelectableText("($name)", style: TextStyle(color: col)),
    SelectableText(val + " ", style: TextStyle(color: col),),
  ],);
}
