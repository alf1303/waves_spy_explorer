import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

class TransView extends StatefulWidget {
  const TransView({Key? key, required this.td}) : super(key: key);
  final dynamic td;

  @override
  State<TransView> createState() => _TransViewState();
}

class _TransViewState extends State<TransView> with AutomaticKeepAliveClientMixin{
  void showDetails() {
    final _trDetailsProvider = TransactionDetailsProvider();
    _trDetailsProvider.setTransaction(widget.td);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy  kk:mm:ss').format(timestampToDate(widget.td["timestamp"]));
    Color color = Colors.white;
    color = getColorByType(widget.td["type"]);
    final fontSize = getFontSize(context);
    return InkWell(
      hoverColor: hoverColor,
      onTap: showDetails,
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Column(
          children: [
          Row(
            children: [
            SizedBox(width: 240, child: LabeledText(label: "type: ", value: getTypeName(widget.td["type"]), name: "${widget.td["type"]}", colr: color, fontSize: fontSize), ),
            SizedBox(width: 300, child: LabeledText(label: "date: ", value: formattedDate, name: "", colr: color, fontSize: fontSize)),
            SizedBox(width: 200, child: LabeledText(label: "height: ", value: widget.td["height"].toString(), name: "", colr: color, fontSize: fontSize)),
            LabeledText(label: "id: ", value: widget.td["id"], name: "", colr: color, fontSize: fontSize),
          ],),
            const Divider(),
            Details(td: widget.td)
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

class Details extends StatelessWidget {
  final dynamic td;
  const Details({Key? key, this.td}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
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
        header = exchangeHeader(p, fontSize);
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
    String out = !isCurrentAddr(dApp) ? "out" : "in";
    String inn = !isCurrentAddr(dApp) ? "in" : "out";
        List<Widget> payList = payment.entries.map((e) => assetBuilder(e.key, e.value, exop, p["exchPriceAsset"], out)).toList();
        List<Widget> inList = transfers.entries.map((e) => assetBuilder(e.key, e.value, exop, p["exchPriceAsset"], inn)).toList();
        // print(td["id"] + ": ");
        // print(inList);
    return  Column(
      children: [
        header,
        Divider(),
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
        )
      ],
    );
  }
}

Widget invokeHeader(Map<String, dynamic> p, double fontSize) {
  return Row(
    children: [
      SizedBox(width: 240, child: LabeledText(label: "function:", value: p["function"], name: "", colr: invokeColor, fontSize: fontSize)),
      SizedBox(width: 500, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: LabeledText(label: "dApp:", value: p["dApp"], name: p["dAppName"], colr: invokeColor, fontSize: fontSize)),),
      SizedBox(child: LabeledText(label: "Sender:", value: p["sender"], name: "", colr: invokeColor, fontSize: fontSize),),
    ],
  );
}

Widget exchangeHeader(Map<String, dynamic> p, double fontSize) {
  return Row(
    children: [
      SizedBox(width: 600,
          child: Row(
            children: [
              LabeledText(label: "sellOrder:", value: "", name: "", colr: exchangeColor, fontSize: fontSize),
              Expanded(child: assetBuilder(p['amountAsset'], p['sellOrder'], false, p['amountAsset'], "out"))
            ],
          )
      ),
      SizedBox(width: 300,
          child: Row(
            children: [
              LabeledText(label: "buyOrder:", value: "", name: "", colr: exchangeColor, fontSize: fontSize),
              Expanded(child: assetBuilder(p['amountAsset'], p['buyOrder'], false, p['amountAsset'], "in"))
            ],
          )
      ),

    ],
  );
}

Widget transferHeader(Map<String, dynamic> p, double fontSize) {
  String suffix = "";
  if(p["direction"] == "IN") {
    suffix = "Received from: ";
  } else {
    suffix = "Sent to: ";
  }
  return Row(
    children: [
      SizedBox(child: LabeledText(label: suffix, value: p["anotherAddr"], name: p["name"], colr: transferColor, fontSize: fontSize),),
      // SizedBox(width: 800, child: LabeledText("dApp:", "${p["dApp"]} (${p["dAppName"]})"),),
    ],
  );
}

Widget massTransferHeader(Map<String, dynamic> p, double fontSize) {
  final _transactionProvider = TransactionProvider();
  return Row(
    children: [
      SizedBox(width: 740, child: LabeledText(label: "From", value: p["anotherAddr"], name: p["name"], colr: massTransferColor, fontSize: fontSize),),
      SizedBox(child: LabeledText(label: "Receiver", value: _transactionProvider.curAddr, name: "", colr: massTransferColor, fontSize: fontSize),),
      // SizedBox(width: 800, child: LabeledText("dApp:", "${p["dApp"]} (${p["dAppName"]})"),),
    ],
  );
}

// TODO
Widget burnHeader(Map<String, dynamic> p) {
  return Container();
}

// Widget assetBuilder2(String id, val, exop, String amountId, String dir, [String? receiver, bool? fail]) {
//   String rec = receiver == null ? "" : " to $receiver";
//   String tmpAss = id + ".|." + amountId;
//   List<Asset?>? assets= getAssetInfoLabelLocal(tmpAss);
//   // print("${assets![0]}, ${assets![1]}");
//   if(assets![0] == null || assets[1] == null && exop) {
//     return assetBuilderFetch(id, val, exop, amountId, dir, receiver, fail);
//   } else {
//     return assetBuilderLocal(id, val, exop, amountId, dir, receiver, fail);
//   }
// }

Widget assetBuilder(String id, val, exop, String amountId, String dir, [String? receiver, bool? fail]) {
  String rec = receiver == null ? "" : " to $receiver";
  String tmpAss = id + ".|." + amountId;
  // print("$id, $val, $exop, $amountId, $dir, $receiver");
  // return Text("fhefsdk");
  bool isNarr = lastIsNarrow();
  double fontSize = !isNarr ? getLastSmallFontSize() : getLastFontSize();
  bool failure = fail ?? false;
  return FutureBuilder<List<Asset?>>(
      future: getAssetInfoLabel(tmpAss),
      builder: (context, snapshot) {
        Widget widget;
        if (snapshot.hasData) {
            // print("${snapshot.data![1]} - $exop, $id, $amountId, $val");
          int decimals = snapshot.data![0]!.decimals;
          double value = val / pow(10, decimals);
          //TODO some strange things with null value
          if (exop) {
            if (snapshot.data![1] != null) {
              int exchDecimals = snapshot.data![1]!.decimals;
              if (id != amountId) {
                value = value / pow(10, 8);
              }
            } else {
              // print("Alarm: ${snapshot.data![0]!.name}");
              // value = 555;
            }
          }
          // print(snapshot.data);
          String vvv = !isNarr ? value.truncat(decimals).toString() : value.truncat(decimals).toStringAsFixed(2);
          widget = value != 0 ?Text("$vvv ${snapshot.data![0]!.name}$rec", style: TextStyle(fontSize: fontSize, color: failure ? disabledColor : dir == "in" ? inAssetsColor : outAssetsColor),) : Container();
          if(value == 555) {
            widget = Container(color: Colors.yellow, child: Text("Alarm", style: TextStyle(fontSize: fontSize),),);
          }
        } else if (snapshot.hasError) {
          print(snapshot.error.toString());
          widget = Text("Error", style: TextStyle(fontSize: fontSize));
        } else {
          widget = Text("loading", style: TextStyle(fontSize: fontSize));
        }
        return widget;
      }
  );
}

Widget assetBuilderLocal(String id, val, exop, String amountId, String dir, [String? receiver, bool? fail]) {
  String rec = receiver == null ? "" : " to $receiver";
  String tmpAss = id + ".|." + amountId;
  // print("$id, $val, $exop, $amountId, $dir, $receiver");
  // return Text("fhefsdk");
  bool isNarr = lastIsNarrow();
  double fontSize = !isNarr ? getLastSmallFontSize() : getLastFontSize();
  bool failure = fail ?? false;

  List<Asset?>? assets = getAssetInfoLabelLocal(tmpAss);
  Widget widget;
    // print("${snapshot.data![1]} - $exop, $id, $amountId, $val");
    int decimals = assets![0]!.decimals;
    double value = val / pow(10, decimals);
    //TODO some strange things with null value
    if (exop) {
      if (assets[1] != null) {
        int exchDecimals = assets[1]!.decimals;
        if (id != amountId) {
          value = value / pow(10, 8);
        }
      } else {
        // print("Alarm: ${snapshot.data![0]!.name}");
        // value = 555;
      }
    }
    // print(snapshot.data);
    String vvv = !isNarr ? value.truncat(decimals).toString() : value.truncat(decimals).toStringAsFixed(2);
    widget = value != 0 ?Text("$vvv ${assets[0]!.name}$rec", style: TextStyle(fontSize: fontSize, color: failure ? disabledColor : dir == "in" ? inAssetsColor : outAssetsColor),) : Container();
    if(value == 555) {
      widget = Container(color: Colors.yellow, child: Text("Alarm", style: TextStyle(fontSize: fontSize),),);
    }
  return widget;


}

class OutWidget extends StatelessWidget {
  const OutWidget({Key? key, required this.payList}) : super(key: key);
  final payList;

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    return Row(
      children: [
        payList.isNotEmpty && !isNarr ? Text("Out --> ", style: TextStyle(fontSize: fontSize, color: outAssetsColor),) : Container(),
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
    final fontSize = getFontSize(context);
    return Row(
      children: [
        income.isNotEmpty && !isNarr ? Text("In <-- ", style: TextStyle(fontSize: fontSize, color: inAssetsColor),) : Container(),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: income,),
        ),
      ],
    );
  }
}

Widget LabeledText({String? label, String? value, String? name, Color? colr, bool? addrLink, required double fontSize}) {
  final labl = label ?? "";
  final val = value ?? "";
  final nam = name ?? "";
  final col = colr ?? Colors.white;
  final aLink = addrLink ?? false;
  final alias = aLink && val.isNotEmpty && val.length != 35;
  double fSize = fontSize;

  return !alias ? LabeledTextLocal(labl: labl, val: val, nam: nam, col: col, aLink: aLink, fontSize: fontSize) :
      FutureBuilder<String>(
        future: fetchAddrByAlias(val),
        builder: (context, snapshot) {
          Widget widget = Text("");
          if(snapshot.hasData) {
            String addr = snapshot.data ?? val;
            widget = LabeledTextLocal(labl: labl, val: "$val->$addr", nam: nam, col: col, aLink: aLink, alias: alias, fontSize: fontSize);
          } else if(snapshot.hasError) {
            print("Err: fetching address by aias: $val");
            widget = LabeledTextLocal(labl: labl, val: val, nam: nam, col: col, aLink: aLink, fontSize: fontSize);
          } else {
            widget = Text("Loading...", style: TextStyle(fontSize: fontSize),);
          }
          return widget;
        },
      );
}



Widget LabeledTextLocal({required String labl, required String val, required String nam, required Color col, required bool aLink, bool? alias, required double fontSize}) {
final bool ali = alias ?? false;
  // print("$labl, $val, $nam");
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      !aLink ?
    Text(labl, style: TextStyle(fontSize: fontSize, color: Colors.grey),) :
    LinkToAddress(val: val, label: labl, alias: ali, fontSize: fontSize,),
    Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            nam == "" ? Text("") : Text("($nam)", style: TextStyle(fontSize: fontSize, color: col)),
            Text(val + " ", style: TextStyle(fontSize: fontSize, color: col),),
          ],
        ),
      ),
    ),
  ],);
}

Widget LabeledTextNoScroll([String? label, String? value, String? name, Color? colr]) {
  final labl = label ?? "";
  final val = value ?? "";
  final nam = name ?? "";
  final col = colr ?? Colors.white;
  final fontSize = getLastFontSize();
  // print("$labl, $val, $nam");
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(labl, style: TextStyle(fontSize: fontSize, color: Colors.grey),),
      nam == "" ? Text("") : SelectableText("($name)", style: TextStyle(fontSize: fontSize, color: col)),
      SelectableText(val + " ", style: TextStyle(fontSize: fontSize, color: col),),
    ],);
}

class LinkToAddress extends StatelessWidget {
  const LinkToAddress({Key? key, required this.val, required this.label, this.color, required this.alias, required this.fontSize}) : super(key: key);
  final String val;
  final String label;
  final Color? color;
  final bool alias;
  final fontSize;

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return       Tooltip(
      message: "Go to $val",
      child: SelectableText.rich(
         TextSpan(
            style: TextStyle(
                shadows: [
                  Shadow(
                      color: color ?? Colors.grey,
                      offset: const Offset(0, -2))
                ],
                fontSize: fontSize,
                color: Colors.transparent,
                decoration: TextDecoration.underline, decorationThickness: 2, decorationColor: Colors.grey),
            text: label,
            recognizer: TapGestureRecognizer()..onTap = () async {
              String baseUri = Uri.base.toString();
              final lastSlash = baseUri.lastIndexOf("#");
              String uri = baseUri.substring(0, lastSlash);
              String addr = "";
              if (alias) {
                addr = val.split("->")[1];
              } else {
                addr = val;
              }
              String link = "$uri?address=$addr";
              await _launchURL(link);
            }
        ),
      ),
    );
  }
}

class LinkToAnyAddress extends StatelessWidget {
  const LinkToAnyAddress({Key? key, required this.val, required this.label, this.color}) : super(key: key);
  final String val;
  final String label;
  final Color? color;

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = getIconSize(context);
    return       Tooltip(
      message: "Go to $label",
      child: IconButton(
        color: Colors.white,
        icon: Icon(Icons.telegram_sharp, size: iconSize,),
        onPressed: () async {
          String baseUri = Uri.base.toString();
          final lastSlash = baseUri.lastIndexOf("/");
          String uri = baseUri.substring(0, lastSlash);
          String addr = "";
          String link = val;
          await _launchURL(link);
        },
      )
    );
  }
}