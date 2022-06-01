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

class SimpleTransView extends StatefulWidget {
  const SimpleTransView({Key? key, required this.td}) : super(key: key);
  final dynamic td;

  @override
  State<SimpleTransView> createState() => _SimpleTransViewState();
}

class _SimpleTransViewState extends State<SimpleTransView> with AutomaticKeepAliveClientMixin{
  void showDetails() {
    final _trDetailsProvider = TransactionDetailsProvider();
    _trDetailsProvider.setTransaction(widget.td);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy  kk:mm:ss').format(timestampToDate(widget.td["timestamp"]));
    Color color = Colors.white;
    color = getColorByType(widget.td["type"]);
    final _transactionProvider = TransactionProvider();
    final type = widget.td["type"];
    bool exop = false;
    Widget header = Text("");

    Map<String, dynamic> p = parseTransactionType(widget.td);
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
        header = issueHeader(p);
        break;
      case "reissue":
        header = issueHeader(p);
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
    if (widget.td.containsKey("dApp")) {dApp = widget.td["dApp"];}
    String out = !isCurrentAddr(dApp) ? "out" : "in";
    String inn = !isCurrentAddr(dApp) ? "in" : "out";
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
              SizedBox(width: 150, child: LabeledText(label: "", value: formattedDate, name: "", colr: color)),
              SizedBox(width: 150, child: LabeledText(label: "", value: getTypeName(widget.td["type"]), name: "${widget.td["type"]}", colr: color), ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(width: 100, child: LabeledText(label: "", value: widget.td["id"], name: "", colr: Colors.grey)),
              ),

              Expanded(
                child: widget.td["type"] == 16 ? SizedBox(width: 350, child: invokeHeader(p)) :
                  widget.td["type"] == 4 ? SizedBox(width: 350, child: transferHeader(p)) :
                      widget.td["type"] == 11 ? SizedBox(width: 350, child: massTransferHeader(p)) :
                          widget.td["type"] == 3 || widget.td["type"] == 5 ? issueHeader(p) :
                            Container(),
              ),
              widget.td["type"] == 3 || widget.td["type"] == 5 ? Container() : Expanded(
                child: SizedBox(child:
                !isCurrentAddr(dApp) ?
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

  @override
  bool get wantKeepAlive => true;
}


Widget invokeHeader(Map<String, dynamic> p) {
  final _trProvider = TransactionProvider();
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(width: 100, child: LabeledText(label: "", value: p["function"], name: "", colr: invokeColor)),
          ),
        ),
        Expanded(child: isCurrentAddr(p["dApp"]) ?
          LabeledText(label: "sender:", value: p["sender"], name: getAddrName(p["sender"]), colr: invokeColor, addrLink: true) :
            LabeledText(label: "dApp:", value: p["dApp"], name: getAddrName(p["dApp"]), colr: invokeColor, addrLink: true)),
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
              LabeledText(label: "sellOrder:", value: "", name: "", colr: exchangeColor),
              Expanded(child: assetBuilder(p['amountAsset'], p['sellOrder'], false, p['amountAsset'], "out"))
            ],
          )
      ),
      SizedBox(width: 300,
          child: Row(
            children: [
              LabeledText(label: "buyOrder:", value: "", name: "", colr: exchangeColor),
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
        Expanded(child: LabeledText(label: suffix, value: p["anotherAddr"], name: "", colr: transferColor, addrLink: true)),
      ],
    ),
  );
}

Widget massTransferHeader(Map<String, dynamic> p) {
  final _transactionProvider = TransactionProvider();
  String lbl = "from";
  if(isCurrentAddr(p["sender"])) {
    lbl = "sender";
  }
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        SizedBox(width: 150, child: Container(),),
        Expanded(child: SizedBox(width: 740, child: LabeledText(label: lbl, value: p["anotherAddr"], name: p["name"], colr: massTransferColor, addrLink: true),)),
      ],
    ),
  );
}

Widget issueHeader(Map<String, dynamic> p) {
  String lbl = "quantity: ";
  Asset? ass = getAssetFromLoaded(p["assetId"]);
  int decimals = 0;
  String name = "";

  if(ass != null) {
    decimals = ass.decimals;
    name = ass.name;
  }
  double quantity = p["quantity"]/pow(10, decimals);
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        // SizedBox(width: 150, child: Container(),),
        Expanded(child: SizedBox(child: LabeledText(label: lbl, value: "${quantity.toString()} $name (${p["assetId"]})", colr: Colors.white),)),
      ],
    ),
  );
}

// TODO
Widget burnHeader(Map<String, dynamic> p) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Container()
  );
}

