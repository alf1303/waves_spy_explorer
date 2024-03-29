import 'dart:math';

import 'package:flutter/material.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:intl/intl.dart';
import 'package:waves_spy/src/models/asset.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/transaction_details_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/styles.dart';
import 'package:waves_spy/src/widgets/other/custom_widgets.dart';
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

  void addTypeToFilter() {
    final filterProvider = FilterProvider();
    filterProvider.changeType(widget.td["type"]);
  }

  @override
  Widget build(BuildContext context) {
    final height = getHeight(context);
    final width = getWidth(context);
    final isMob = isPortrait(context);
    final fontSize = getSmallFontSize(context);
    final iconSize = getIconSize(context);
    final textStyle = TextStyle(fontSize: fontSize);
    final isNarr = isNarrow(context);
    String formattedDate = DateFormat('dd-MM-yyyy  kk:mm:ss').format(timestampToDate(widget.td["timestamp"]));
    Color color = Colors.white;
    color = getColorByType(widget.td["type"]);
    final _transactionProvider = TransactionProvider();
    final filterProvider = FilterProvider();
    final type = widget.td["type"];
    bool exop = false;
    Widget header = Text("");

    Map<String, dynamic> p = parseTransactionType(widget.td);
    exop = p['exchPriceAsset'] == " " ? false : true;
    Map<String, double> payment = p['payment'];
    Map<String, double> transfers = p["transfers"];
    switch (p['header']) {
      case "invoke":
        header = invokeHeader(p, fontSize);
        break;
      case "transfer":
        header = transferHeader(p, fontSize);
        break;
      case "massTransfer":
        header = massTransferHeader(p, fontSize);
        break;
      case "burn":
        header = burnHeader(p);
        break;
      case "exchange":
        header = exchangeHeader(p, widget.td, fontSize);
        break;
    // TODO implement:
      case "setScript":
        break;
      case "data":
        break;
      case "alias":
        break;
      case "issue":
        header = issueHeader(p, fontSize);
        break;
      case "reissue":
        header = issueHeader(p, fontSize);
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
    final fail = widget.td["additional"]["fail"];
    List<Widget> payList = payment.entries.map((e) => assetBuilder(e.key, e.value, exop, p["exchPriceAsset"], out, null, fail)).toList();
    List<Widget> inList = transfers.entries.map((e) => assetBuilder(e.key, e.value, exop, p["exchPriceAsset"], inn, null, fail)).toList();
    final count = widget.td["additional"]["tradeAddrCount"];
    // print(count);
    color = fail ? Colors.grey : color;
    final borderColor = fail ? Colors.red : filterProvider.highlightTradeAccs ? count == 2 ? Colors.yellow : count == 1 ? Colors.lightGreen : Colors.grey : Colors.grey;
    final typeName = isNarr ? getTypeName(widget.td["type"]).split(" ")[0] : getTypeName(widget.td["type"]);
    final typeNumber = isNarr ? "" : widget.td["type"];
    final dateStr = isNarr ? formattedDate.substring(0, 10) : formattedDate;
    return InkWell(
      hoverColor: hoverColor,
      onTap: showDetails,
      child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            // color: fail ? Colors.white12 : null,
              border: Border.all(color: borderColor), borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: width*0.09, child: LabeledText(label: "", value: dateStr, name: "", colr: color.withOpacity(0.5), fontSize: fontSize)),
              SizedBox(width: width*0.09, child: Row(
                children: [
                  InkWell(
                    onLongPress: () {copyToClipboard(typeName);},
                      onTap: addTypeToFilter,
                      child: Text("($typeNumber)$typeName", style: TextStyle(fontSize: fontSize, color: color),)),
                      // child: LabeledText(label: "", value: typeName, name: "$typeNumber", colr: color, fontSize: fontSize)),
                
                  Expanded(child: Container())
                ],
              ), ),
              !isNarr ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(width: 100, child: LabeledText(label: "", value: widget.td["id"], name: "", colr: Colors.grey, fontSize: fontSize)),
              ): SizedBox(),

              Expanded(
                child: widget.td["type"] == 16 ? SizedBox(width: 350, child: invokeHeader(p, fontSize)) :
                  widget.td["type"] == 4 ? SizedBox(width: 350, child: transferHeader(p, fontSize)) :
                      widget.td["type"] == 11 ? SizedBox(width: 350, child: massTransferHeader(p, fontSize)) :
                          widget.td["type"] == 3 || widget.td["type"] == 5 ? issueHeader(p, fontSize) :
                              widget.td["type"] == 13 ? scriptHeader(widget.td, fontSize, context) :
                                  widget.td["type"] == 7 ? SizedBox(width: 350, child: exchangeHeader(p, widget.td, fontSize)) :
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


Widget invokeHeader(Map<String, dynamic> p, double fontSize) {
  final filterProvider = FilterProvider();
  
  void onFunctionTap() {
    if(filterProvider.fType.contains(16) && filterProvider.functName == p["function"]) {
      filterProvider.fType.clear();
      filterProvider.clearFunc();
      return;
    }
    if(filterProvider.fType.contains(16) && filterProvider.functName != p["function"]) {
      // filterProvider.fType.clear();
      filterProvider.changeFunctionName(p["function"]);
      return;
    }
    if(!filterProvider.fType.contains(16)) {
      filterProvider.fType.add(16);
      filterProvider.changeFunctionName(p["function"]);
    }
  }

  void addAddressToFilter() {
    if (p["sender"] == filterProvider.addrName || p["dApp"] == filterProvider.addrName) {
      filterProvider.clearAddress();
      return;
    }
    if(isCurrentAddr(p["dApp"])) {
      filterProvider.changeAddressName(p["sender"]);
    } else {
      filterProvider.changeAddressName(p["dApp"]);
    }
  }
  final fail = p["fail"];
  final flexSpace = (25/(p["function"].length)).round();
  final flexFunc = 25 - flexSpace;
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
                // width: fontSize*10000,
                child: Row(
                  children: [
                    Flexible(
                    flex: flexFunc,
                      child: InkWell(
                          onLongPress: () {copyToClipboard(p["function"]);},
                          onTap: onFunctionTap,
                      // child: LabeledText(label: "", value: p["function"], name: "", colr: fail? disabledColor : invokeColor, fontSize: fontSize)
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(p["function"], style: TextStyle(color: fail? disabledColor : invokeColor, fontSize: fontSize),))
                      ),
                    ),
                    Flexible(
                      flex: flexSpace,
                      fit: FlexFit.loose,
                      child: Container(),)
                  ],
                )
            ),
          ),
        ),
        Expanded(child: isCurrentAddr(p["dApp"]) ?
          InkWell(
              onLongPress: () {copyToClipboard(p["sender"]);},
              onTap: addAddressToFilter,
              child: LabeledText(label: "sender:", value: p["sender"], name: getAddrName(p["sender"]), colr: fail? disabledColor : invokeColor, addrLink: true, fontSize: fontSize)) :
            InkWell(
                onLongPress:  () {copyToClipboard(p["dApp"]);},
                onTap: addAddressToFilter,
                child: LabeledText(label: "dApp:", value: p["dApp"], name: getAddrName(p["dApp"]), colr: fail? disabledColor : invokeColor, addrLink: true, fontSize: fontSize))),
      ],
    ),
  );
}

Widget exchangeHeader(Map<String, dynamic> p, Map<String, dynamic> tr, double fontSize) {
  final fail = p["fail"] ?? false;
  // print(p);
  // print("befCalc ${tr["id"]}");
  final price = calcExchPrice(tr);
  // print("afterCalc");
  void addSellerToFilter() {
    if(p["seller"] == filterProvider.addrName) {
      filterProvider.clearAddress();
    } else {
      filterProvider.changeAddressName(p["seller"]);
    }
  }

  void addBuyerToFilter() {
    if(p["buyer"] == filterProvider.addrName) {
      filterProvider.clearAddress();
    } else {
      filterProvider.changeAddressName(p["buyer"]);
    }
  }

  return Row(
    children: [
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
                onLongPress: () {copyToClipboard(p["seller"]);},
                onTap: addSellerToFilter,
                child: SizedBox(width: fontSize*10, child: LabeledText(label: "seller", value: p["seller"], name: getAddrName(p["seller"]), colr: fail ? disabledColor : const Color.fromARGB(255, 255, 150, 150), addrLink: true, fontSize: fontSize))
            ),
            InkWell(
                onLongPress: () {copyToClipboard(p["buyer"]);},
                onTap: addBuyerToFilter,
                child: SizedBox(width: fontSize*10, child: LabeledText(label: "buyer", value: p["buyer"], name: getAddrName(p["buyer"]), colr: fail ? disabledColor : const Color.fromARGB(255, 150, 255, 150), addrLink: true, fontSize: fontSize))
            ),

          ],
        ),
      ),
      Expanded(child: Text("$price", style: TextStyle(fontSize: fontSize*0.8, color: Colors.yellowAccent),)),
      SizedBox(width: fontSize/3,)
    ],
  );
}

Widget transferHeader(Map<String, dynamic> p, double fontSize) {
  void addAddressToFilter() {
    if(p["anotherAddr"] == filterProvider.addrName) {
      filterProvider.clearAddress();
    } else {
      filterProvider.changeAddressName(p["anotherAddr"]);
    }
  }

  final fail = p["fail"];
  String suffix = "";
  if(p["direction"] == "IN") {
    suffix = "from: ";
  } else {
    suffix = "to: ";
  }
  final flexSpace = (350/p["anotherAddr"].length).round();
  final flexAddr = 350 - flexSpace;
  // print("$flexAddr, $flexSpace");
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        SizedBox(width: fontSize*0.07, child: Container(),),
        Flexible(
            flex: 8,
            fit: FlexFit.tight,
            child: InkWell(
            onLongPress: () {copyToClipboard(p["anotherAddr"]);},
            onTap: addAddressToFilter,
            child: LabeledText(label: suffix, value: p["anotherAddr"], name: getAddrName(p["anotherAddr"]), colr: fail ? disabledColor : transferColor, addrLink: true, fontSize: fontSize)
        )),
        Flexible(
            flex: 1,
            child: Container())
      ],
    ),
  );
}

Widget massTransferHeader(Map<String, dynamic> p, double fontSize) {
  void addAddressToFilter() {
    if(p["anotherAddr"] == filterProvider.addrName) {
      filterProvider.clearAddress();
    } else {
      filterProvider.changeAddressName(p["anotherAddr"]);
    }  }

  final fail = p["fail"];
  String lbl = "from";
  if(isCurrentAddr(p["sender"])) {
    lbl = "sender";
  }
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        SizedBox(width: fontSize*0.07, child: Container(),),
        Expanded(child: SizedBox(width: 740, child: InkWell(
            onLongPress: () {copyToClipboard(p["anotherAddr"]);},
            onTap: addAddressToFilter,
            child: LabeledText(label: lbl, value: p["anotherAddr"], name: p["name"], colr: fail ? disabledColor : massTransferColor, addrLink: true, fontSize: fontSize)),)),
      ],
    ),
  );
}

Widget issueHeader(Map<String, dynamic> p, double fontSize) {
  final fail = p["fail"];
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
        Expanded(child: SizedBox(child: LabeledText(label: lbl, value: "${quantity.toString()} $name (${p["assetId"]})", colr: fail ? disabledColor : Colors.white, fontSize: fontSize),)),
      ],
    ),
  );
}

Widget scriptHeader(dynamic t, double fontSize, BuildContext context) {
  final fail = t["additional"]["fail"];
  final fontSize = getFontSize(context);
  final iconSize = getIconSize(context);
  TextStyle textStyle = TextStyle(fontSize: fontSize);
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      children: [
        // SizedBox(width: 150, child: Container(),),
        // Expanded(child: SizedBox(child: LabeledText(label: lbl, value: "${quantity.toString()} $name (${p["assetId"]})", colr: fail ? disabledColor : Colors.white, fontSize: fontSize),)),
        TextButton(onPressed: () {
          final script = t["script"];
          showDialog(context: context, 
              builder: (context) {
            return MyDialog(
                child: FutureBuilder<String>(
                  future: decodeScript(script),
                  builder: (context, snapshot) {
                    Widget widget;
                    if(snapshot.hasData) {
                      widget = SingleChildScrollView(scrollDirection: Axis.vertical, child: SelectableText(snapshot.data!));
                    } else if(snapshot.hasError) {
                      widget = Text("Error: ${snapshot.error}", style: textStyle,);
                    } else {
                      widget = SizedBox(width: fontSize*50, height: fontSize*50, child: Center(child: CircularProgressIndicator()));
                    }
                    return widget;
                  },
                ), 
                iconSize: 16);
              });
        },
            child: Text("View Script"))
      ],
    ),
  );
}



// TODO
Widget burnHeader(Map<String, dynamic> p) {
  final fail = p["fail"];
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Container()
  );
}

