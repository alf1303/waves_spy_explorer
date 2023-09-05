import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:waves_spy/src/arb_blocks/blocks_provider.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

const nodeUrl = "https://nodes.wavesnodes.com/";

Future<Map<String, dynamic>> getBlockData(int blockNumber) async {
  // await Future.delayed(Duration(seconds: 4), () => {});
  // return ["abc", "def"];
  String reqStr = "";
  Map<String, dynamic> result = {};
  reqStr = "${nodeUrl}blocks/at/${blockNumber}";

  var resp = await http.get(Uri.parse(reqStr));
  if (resp.statusCode == 200) {
    final json = jsonDecode(resp.body);
    final trxs = json["transactions"].where((t) => t["type"] == 16 || t["type"] == 7).toList();
    return {
      "height": json["height"],
      "id": json["id"],
      "generator": json["generator"],
      "transactions": trxs
    };
    return json;
  } else {
    return result;
  }
  return result;
}

Future<Map<String, dynamic>> getTx() async {
  final blocksProvider = BlocksProvider();
  Map<String, dynamic> result = {};
  String reqStr = "";
  reqStr = "${nodeUrl}transactions/info/${blocksProvider.txid}";
  var resp = await http.get(Uri.parse(reqStr));
  if (resp.statusCode == 200) {
    final json = jsonDecode(resp.body);
    return json;
  } else {
    return result;
  }
}

Future<Map<String, dynamic>> getData() async {
  final blocksProvider = BlocksProvider();
  Map<String, dynamic> result = {};
  int block = blocksProvider.block;
  if (!blocksProvider.byBlock) {
    final txdata = await getTx();
    block = txdata["height"];
  }
  result = await getBlockData(block);
  // print(result);
  return result;
}

final List<String> myDapps = ["3PNASfdCWXvYfErZXoKhVbi7XrbJw1SJvfg", "3PBeerh759eA1eGFuw77RowaZfZNohzJzvz"];
final List<String> botAddresses = ["3PNASfdCWXvYfErZXoKhVbi7XrbJw1SJvfg", "3PBeerh759eA1eGFuw77RowaZfZNohzJzvz", "3P5ji1wvrDLQxgK5c3cGbiSwiZfu5x1S3VR", "3PRE5KH9oPGfFPs7fGnQcJ4wNshEDUPGj1t", "3PQ23xgnf98t4qDtF5bscxdCDwgYoL7SPeK", "3PMbnqiffrx5NRAsgun6bGdE4T4M9gxWLgg"];
final au = ["3P8auNWJkxxByyJtwErFXaxiXcGM45qQ1hA"];
bool my(Map<String, dynamic> tx) {
  if (tx["type"] == 16) {
    final String dApp = tx["dApp"];
    if (myDapps.contains(dApp)) {
      return true;
    }
  }
  return false;
}

bool bot(Map<String, dynamic> tx) {
  if (tx["type"] == 16) {
    final String dApp = tx["dApp"];
    final String sender = tx["sender"];
    if (botAddresses.contains(dApp) || botAddresses.contains(sender)) {
      return true;
    }
  }
  return false;
}

MaterialStateProperty<Color> getRowColor(Map<String, dynamic> tx, {String targetTx = ""}) {
  MaterialStateProperty<Color> color = MaterialStateProperty.all<Color>(Colors.black);
  if (targetTx.isNotEmpty) {
    color = tx["id"] == targetTx ? MaterialStateProperty.all<Color>(Colors.black12) : color;
  }
  return color;
}

Decoration getBorder(Map<String, dynamic> tx) {
  if (my(tx)) {
    return BoxDecoration(border: Border.all(color: Colors.grey),
        borderRadius: const BorderRadius.all(Radius.circular(5)));
  }
  return BoxDecoration();
}

TextStyle getTextStyle(Map<String, dynamic> tx) {
  if (bot(tx)) {
    return TextStyle(color: Colors.orange[200]);
  }
  if (tx["sender"] == au[0]) {
    return TextStyle(color: Colors.deepOrange[200]);
  }
  return const TextStyle(color: Colors.white70);
}

Widget getType(Map<String, dynamic> tx) {
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: getBorder(tx),
    child: SelectableText("${tx['type']}", style: getTextStyle(tx),),
  );
}

Widget getFunction(Map<String, dynamic> tx) {
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: getBorder(tx),
    child: SelectableText("${tx['type'] == 16 ? tx['call']['function'] : "<---->"}", style: getTextStyle(tx)),
  );
}

Widget getId(Map<String, dynamic> tx) {
  final iconSize = getLastFontSize();
  return Container(
    padding: const EdgeInsets.all(3),
    // decoration: getBorder(tx),
    child: Row(
      children: [
        SelectableText.rich(
          TextSpan(
              style: getTextStyle(tx).copyWith(decoration: TextDecoration.underline, decorationThickness: 2, decorationColor: Colors.grey),
              text: tx['id'].substring(0, 10),
              recognizer: TapGestureRecognizer()..onTap = () async {
                _launchURL("https://wavesexplorer.com/ru/transactions/${tx['id']}");
              }
          ),
        ),
        IconButton(onPressed: () {copyToClipboard(tx["id"].substring(0, 10));},
            icon: Icon(Icons.copy, size: iconSize,))
      ],
    ),
  );
}

_launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Widget getDapp(Map<String, dynamic> tx) {
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: getBorder(tx),
    child: SelectableText("${tx['type'] == 16 ? tx['dApp'] : ''}", style: getTextStyle(tx)),
  );
}

Widget getSender(Map<String, dynamic> tx) {
  final sender = tx["sender"];
  final iconSize = getLastFontSize();
  return Container(
    padding: const EdgeInsets.all(3),
    // decoration: getBorder(tx),
    // child: SelectableText("${tx['sender']}", style: getTextStyle(tx)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        LinkToAddress(label: sender, val: sender, alias: false),
        IconButton(onPressed: () {copyToClipboard(tx["sender"]);},
            icon: Icon(Icons.copy, size: iconSize,))
      ],
    ),
  );
}

Widget getStatus(Map<String, dynamic> tx) {
  final status = tx['applicationStatus'] != 'succeeded';
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: getBorder(tx),
    child: status ? const Icon(Icons.close, color: Colors.red,) : const Icon(Icons.check_rounded, color: Colors.green,),
  );
}