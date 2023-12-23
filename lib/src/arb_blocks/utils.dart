import 'dart:convert';
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:waves_spy/src/arb_blocks/blocks_provider.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/asset.dart';
import 'package:waves_spy/src/widgets/other/custom_widgets.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

const nodeUrl = "https://nodes.wavesnodes.com/";

Future<Map<String, dynamic>> getBlockData(int blockNumber) async {
  // await Future.delayed(Duration(seconds: 4), () => {});
  // return ["abc", "def"];
  String reqStr = "";
  Map<String, dynamic> result = {};
  reqStr = "${nodeUrl}blocks/at/${blockNumber}";
  var newTrxs = [];
  var resp = await http.get(Uri.parse(reqStr));
  if (resp.statusCode == 200) {
    final json = jsonDecode(resp.body);
    final trxs = json["transactions"].where((t) => t["type"] == 16 || t["type"] == 7).toList();
    final jsonPayload = {"ids": trxs.map((trx) => trx["id"]).toList()};
    final jsonString = jsonEncode(jsonPayload);
    final response = await http.post(
      Uri.parse('https://nodes.wavesnodes.com/transactions/info'),
      headers: {'Content-Type': 'application/json'},
      body: jsonString,
    );
    if (resp.statusCode == 200) {
      newTrxs = jsonDecode(response.body);
    }
    // print(newTrxs[4]);
    // print(trxs[4]);
    return {
      "height": json["height"],
      "id": json["id"],
      "generator": json["generator"],
      "transactions": newTrxs
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
  // print(blocksProvider.txid);
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

bool byFunc(String functionName) {
  const allowedFunctions = ["putOneTkn"];
  return allowedFunctions.contains(functionName);
}

final List<String> myDapps = ["3PNASfdCWXvYfErZXoKhVbi7XrbJw1SJvfg", "3PBeerh759eA1eGFuw77RowaZfZNohzJzvz"];
final List<String> botAddresses = ["3PNASfdCWXvYfErZXoKhVbi7XrbJw1SJvfg", "3PBeerh759eA1eGFuw77RowaZfZNohzJzvz", "3P5ji1wvrDLQxgK5c3cGbiSwiZfu5x1S3VR", "3PRE5KH9oPGfFPs7fGnQcJ4wNshEDUPGj1t", "3PQ23xgnf98t4qDtF5bscxdCDwgYoL7SPeK", "3PMbnqiffrx5NRAsgun6bGdE4T4M9gxWLgg"];
final au = ["3P8auNWJkxxByyJtwErFXaxiXcGM45qQ1hA"];
const rex = "3PGFHzVGT4NTigwCKP1NcwoXkodVZwvBuuU";
const keeper = "3P5UKXpQbom7GB2WGdPG5yGQPeQQuM3hFmw";
const wxSwap = "3P68zNiufsu1viZpu1aY3cdahRRKcvV5N93";
const swappers = [rex, keeper, wxSwap];

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
    color = tx["id"] == targetTx ? MaterialStateProperty.all<Color>(Colors.indigo.shade900) : color;
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
  String dappName = "";
  if (tx['type'] == 16) {
    dappName = tx['dApp'];
    if (tx['dApp'] == rex) {
        dappName = "REX";
    }
    if (tx['dApp'] == keeper) {
      dappName = "KEEPER";
    }
    if (tx['dApp'] == wxSwap) {
      for (var i in tx["stateChanges"]["invokes"]) {
        final func = i["call"]["function"];
        if (func == "calculateAmountOutForSwapAndSendTokens") {
          dappName = "WX (${i['dApp']})";
        }
      }

    }
  }
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: getBorder(tx),

    child: SelectableText(dappName, style: getTextStyle(tx)),
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
        LinkToAddress(label: sender.substring(0,10), val: sender, alias: false),
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

class TxInfo extends StatelessWidget {
  final Map<String, dynamic> tx;

  TxInfo({Key? key, required this.tx}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sender = tx["sender"];
    final type = tx["type"];
    final iconSize = getLastFontSize();
    final blocksProvider = BlocksProvider();
    List<String> pools = List.empty(growable: true);
    String pools_str = "";
    Widget child = Container(child: Text("No data"));
    if (type == 7) {
      // print("tx: ${tx}");
      child = FutureBuilder<Map<String, dynamic>>(
        future: blocksProvider.getTxData(tx["id"]),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final data = snapshot.data ?? {};
            // print(data);
            final addr1 = data["order1"]["sender"];
            final addr2 = data["order2"]["sender"];
            final addr1IsPool = blocksProvider.wxPools.contains(addr1);
            final addr2IsPool = blocksProvider.wxPools.contains(addr2);
            final amountId = data["order1"]["assetPair"]["amountAsset"] ?? "WAVES";
            final priceId = data["order1"]["assetPair"]["priceAsset"] ?? "WAVES";

            data["additional"] = <String, dynamic>{};
            data["additional"]["fail"] = false;
            Map<String, dynamic> p = parseTransactionType(data);
            final exop = p['exchPriceAsset'] == " " ? false : true;
            Map<String, double> payment = p['payment'];
            Map<String, double> transfers = p["transfers"];
            List<Widget> payList = payment.entries.map((e) => assetBuilder(e.key, e.value, exop, p["exchPriceAsset"], "in", null)).toList();
            List<Widget> inList = transfers.entries.map((e) => assetBuilder(e.key, e.value, exop, p["exchPriceAsset"], "out", null)).toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Addresses:"),
                Text(addr1, style: TextStyle(color: addr1IsPool ? Colors.greenAccent : Colors.white70)),
                Text(addr2, style: TextStyle(color: addr2IsPool ? Colors.greenAccent : Colors.white70)),
                Divider(),
                Text("Assets:"),
                Row(
                  children: [
                    Text(amountId, style: TextStyle(color: Colors.white70)),
                    AssetName(id: amountId)
                  ],
                ),
                Row(
                  children: [
                    Text(priceId, style: TextStyle(color: Colors.white70)),
                    AssetName(id: priceId)
                  ],
                ),
                SizedBox(width: 600, height: 70,
                  child: Row(
                    children: [
                      payList.isNotEmpty ? Expanded(child: OutWidget(payList: payList,)) : Container(),
                      transfers.isNotEmpty ? Expanded(child: InWidget(income: inList,)) : Container()
                    ],
                  ),
                )
            ],);
          } else {
            // print(snapshot);
            return Text("Some error or no data");
          }
        });

    }
    else if (type == 16 && sender == "3PQ23xgnf98t4qDtF5bscxdCDwgYoL7SPeK" && tx["call"]["function"] == "x") {
      if (tx["applicationStatus"] == "script_execution_failed") {
        return Text("Failed tx");
      }
      final data = tx["stateChanges"]["data"];
      final profit_assetId = data.isNotEmpty ? data[0]["key"].split("_")[1] : "";
      final profit_amount = data.isNotEmpty ? data[0]["value"]: 0;
      Widget profit = data.isNotEmpty ? assetBuilderSimple(profit_assetId, val: profit_amount, lbl: "Profit:") : Container();

      List<Map<String, dynamic>> assets = List.empty(growable: true);
      List<Map<String, String>> pools = List.empty(growable: true);

      for (var i in tx["stateChanges"]["invokes"]) {
        String dapp = i["dApp"];
        String func = i["call"]["function"];
        if (func != "y") {
          // print("--> ${i}");
          List<dynamic> payments = i["payment"] ?? List.empty(growable: true);
          if (payments.isNotEmpty) {
            String assetId = payments[0]["assetId"] ?? "WAVES";
            final amount = payments[0]["amount"];
            assets.add({"assetId": assetId, "amount": amount});
          }
          if (dapp != "3PLoX5yufZz9jRahL1CVVRAXq8VpUmXBKLK") {
            if (dapp == "3P68zNiufsu1viZpu1aY3cdahRRKcvV5N93") {
              var invs = i["stateChanges"]["invokes"];
              var resultMap = invs.firstWhere((element) => element["call"]["function"] == "calculateAmountOutForSwapAndSendTokens", orElse: () => null);
              pools.add({"pool": resultMap != null ? resultMap["dApp"] : "unknown", "type": "wx"});
            } else {
              pools.add({"pool": dapp, "type": blocksProvider.getPoolType(dapp)});
            }
          }
        }
      }
      print(tx["id"]);
      print(assets);
      List<Widget> payList = assets.isNotEmpty ? assets.map((e) => assetBuilderSimple(e["assetId"], val: e["amount"])).toList() : [Container()];
      child = Container(width: 600, height: 400, child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profit,
          Divider(),
          Text("Assets:"),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: payList,),
          Divider(),
          Text("Pools:"),
          ListView.builder(
              shrinkWrap: true,
              itemCount: pools.length,
              itemBuilder: (context, index) {
                String pool_adr = pools[index]["pool"] ?? "undefined";
                String? type = pools[index]["type"];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinkToAddress(label: "$pool_adr ($type)", val: pool_adr, alias: false, color: Colors.white70,),
                    IconButton(onPressed: () {copyToClipboard(pool_adr);},
                        icon: Icon(Icons.copy, size: iconSize,))
                  ],
                );
              }),
        ],
      ),);
    }
    else if (type == 16 && (sender == "3PLET96WmdYmHzqkEHB6Ufj1F2kREgnCzDc" || sender == "3P7AiH8YmJNqLaWeYm21bM4pD5iFnBrAyt1")) {
      // if (tx["applicationStatus"] == "script_execution_failed") {
      //   return Text("Failed tx");
      // }
      final ptransfers = tx["stateChanges"]["invokes"][0]["stateChanges"]["transfers"];
      final profit_assetId = ptransfers.isNotEmpty ? ptransfers[1]["asset"] ?? "WAVES" : "";
      final profit_amount = ptransfers.isNotEmpty ? ptransfers[1]["amount"] : 0;
      final out_amount = ptransfers.isNotEmpty ? ptransfers[0]["amount"] + ptransfers[1]["amount"] : 0;
      Widget profit = assetBuilderSimple(profit_assetId, val: profit_amount, lbl: "Profit:");

      List<Map<String, dynamic>> assets = List.empty(growable: true);
      List<Map<String, String>> pools = List.empty(growable: true);

      for (var i in tx["stateChanges"]["invokes"][0]["stateChanges"]["invokes"]) {
        String dapp = i["dApp"];
        String func = i["call"]["function"];
        if (func != "y") {
          // print("--> ${i}");
          List<dynamic> payments = i["payment"] ?? List.empty(growable: true);
          if (payments.isNotEmpty) {
            String assetId = payments[0]["assetId"] ?? "WAVES";
            final amount = payments[0]["amount"];
            assets.add({"assetId": assetId, "amount": amount});
          }
          if (dapp != "3PLoX5yufZz9jRahL1CVVRAXq8VpUmXBKLK") {
            if (dapp == "3P68zNiufsu1viZpu1aY3cdahRRKcvV5N93") {
              var invs = i["stateChanges"]["invokes"];
              var resultMap = invs.firstWhere((element) => element["call"]["function"] == "calculateAmountOutForSwapAndSendTokens", orElse: () => null);
              pools.add({"pool": resultMap != null ? resultMap["dApp"] : "unknown", "type": "wx"});
            } else {
              pools.add({"pool": dapp, "type": blocksProvider.getPoolType(dapp)});
            }
          }
        }
      }
      List<Widget> payList = assets.map((e) => assetBuilderSimple(e["assetId"], val: e["amount"])).toList();
      payList.add(assetBuilderSimple(profit_assetId, val: out_amount));
      child = Container(width: 600, height: 400, child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profit,
          Divider(),
          Text("Assets:"),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: payList,),
          Divider(),
          Text("Pools:"),
          ListView.builder(
              shrinkWrap: true,
              itemCount: pools.length,
              itemBuilder: (context, index) {
                String pool_adr = pools[index]["pool"] ?? "undefined";
                String? type = pools[index]["type"];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinkToAddress(label: "$pool_adr ($type)", val: pool_adr, alias: false, color: Colors.white70,),
                    IconButton(onPressed: () {copyToClipboard(pool_adr);},
                        icon: Icon(Icons.copy, size: iconSize,))
                  ],
                );
              }),
        ],
      ),);
    }
    else if (type == 16 && (sender == "3PMbnqiffrx5NRAsgun6bGdE4T4M9gxWLgg")) {
      if (tx["applicationStatus"] == "script_execution_failed") {
        return Text("Failed tx");
      }
      final ptransfers = tx["stateChanges"]["invokes"][0]["stateChanges"]["transfers"];
      final profit_assetId = ptransfers.isNotEmpty ? ptransfers[0]["asset"] ?? "WAVES" : "";
      final profit_amount = ptransfers.isNotEmpty ? ptransfers[0]["amount"] : 0;
      final out_amount = ptransfers.isNotEmpty ? ptransfers[0]["amount"] + ptransfers[1]["amount"] : 0;
      Widget profit = assetBuilderSimple(profit_assetId, val: profit_amount, lbl: "Profit:");

      List<Map<String, dynamic>> assets = List.empty(growable: true);
      List<Map<String, String>> pools = List.empty(growable: true);

      for (var i in tx["stateChanges"]["invokes"][0]["stateChanges"]["invokes"]) {
        String dapp = i["dApp"];
        String func = i["call"]["function"];
        if (func != "w") {
          // print("--> ${i}");
          List<dynamic> payments = i["payment"] ?? List.empty(growable: true);
          if (payments.isNotEmpty) {
            String assetId = payments[0]["assetId"] ?? "WAVES";
            final amount = payments[0]["amount"];
            assets.add({"assetId": assetId, "amount": amount});
          }
          if (dapp != "3PLoX5yufZz9jRahL1CVVRAXq8VpUmXBKLK") {
            if (dapp == "3P68zNiufsu1viZpu1aY3cdahRRKcvV5N93") {
              var invs = i["stateChanges"]["invokes"];
              var resultMap = invs.firstWhere((element) => element["call"]["function"] == "calculateAmountOutForSwapAndSendTokens", orElse: () => null);
              pools.add({"pool": resultMap != null ? resultMap["dApp"] : "unknown", "type": "wx"});
            } else {
              pools.add({"pool": dapp, "type": blocksProvider.getPoolType(dapp)});
            }
          }
        }
      }
      List<Widget> payList = assets.map((e) => assetBuilderSimple(e["assetId"], val: e["amount"])).toList();
      payList.add(assetBuilderSimple(profit_assetId, val: out_amount));
      child = Container(width: 600, height: 600, child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profit,
          Divider(),
          Text("Assets:"),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: payList,),
          Divider(),
          Text("Pools:"),
          ListView.builder(
              shrinkWrap: true,
              itemCount: pools.length,
              itemBuilder: (context, index) {
                String pool_adr = pools[index]["pool"] ?? "undefined";
                String? type = pools[index]["type"];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinkToAddress(label: "$pool_adr ($type)", val: pool_adr, alias: false, color: Colors.white70,),
                    IconButton(onPressed: () {copyToClipboard(pool_adr);},
                        icon: Icon(Icons.copy, size: iconSize,))
                  ],
                );
              }),
        ],
      ),);
    }
    else if (type == 16 && (sender == "3PRE5KH9oPGfFPs7fGnQcJ4wNshEDUPGj1t")) {
      if (tx["applicationStatus"] == "script_execution_failed") {
        return Text("Failed tx");
      }
      final ptransfers = tx["stateChanges"]["transfers"];
      final payment = tx["stateChanges"]["invokes"][0]["payment"][0];

      final profit_assetId = ptransfers.isNotEmpty ? ptransfers[0]["asset"] ?? "WAVES" : "";
      final profit_amount = ptransfers.isNotEmpty ? ptransfers[0]["amount"] : 0;
      final out_amount = payment["amount"];
      Widget profit = assetBuilderSimple(profit_assetId, val: profit_amount, lbl: "Profit:");

      List<Map<String, dynamic>> assets = List.empty(growable: true);
      List<Map<String, String>> pools = List.empty(growable: true);

      for (var i in tx["stateChanges"]["invokes"]) {
        String dapp = i["dApp"];
        String func = i["call"]["function"];
        if (func != "w") {
          // print("--> ${i}");
          List<dynamic> payments = i["payment"] ?? List.empty(growable: true);
          if (payments.isNotEmpty) {
            String assetId = payments[0]["assetId"] ?? "WAVES";
            final amount = payments[0]["amount"];
            assets.add({"assetId": assetId, "amount": amount});
          }
          if (dapp != "3PLoX5yufZz9jRahL1CVVRAXq8VpUmXBKLK") {
            if (dapp == "3P68zNiufsu1viZpu1aY3cdahRRKcvV5N93") {
              var invs = i["stateChanges"]["invokes"];
              var resultMap = invs.firstWhere((element) => element["call"]["function"] == "calculateAmountOutForSwapAndSendTokens", orElse: () => null);
              pools.add({"pool": resultMap != null ? resultMap["dApp"] : "unknown", "type": "wx"});
            } else {
              pools.add({"pool": dapp, "type": blocksProvider.getPoolType(dapp)});
            }
          }
        }
      }
      List<Widget> payList = assets.map((e) => assetBuilderSimple(e["assetId"], val: e["amount"])).toList();
      payList.add(assetBuilderSimple(profit_assetId, val: out_amount));
      child = Container(width: 600, height: 400, child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profit,
          Divider(),
          Text("Assets:"),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: payList,),
          Divider(),
          Text("Pools:"),
          ListView.builder(
              shrinkWrap: true,
              itemCount: pools.length,
              itemBuilder: (context, index) {
                String pool_adr = pools[index]["pool"] ?? "undefined";
                String? type = pools[index]["type"];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinkToAddress(label: "$pool_adr ($type)", val: pool_adr, alias: false, color: Colors.white70,),
                    IconButton(onPressed: () {copyToClipboard(pool_adr);},
                        icon: Icon(Icons.copy, size: iconSize,))
                  ],
                );
              }),
        ],
      ),);
    }
    else if (type == 16) {
      if (tx["applicationStatus"] == "script_execution_failed") {
        return Text("Failed tx");
      }
      // final ptransfers = tx["stateChanges"]["invokes"][0]["stateChanges"]["transfers"];
      // final profit_assetId = ptransfers.isNotEmpty ? ptransfers[0]["asset"] ?? "WAVES" : "";
      // final profit_amount = ptransfers.isNotEmpty ? ptransfers[0]["amount"] : 0;
      // final out_amount = ptransfers.isNotEmpty ? ptransfers[0]["amount"] + ptransfers[1]["amount"] : 0;
      // Widget profit = assetBuilderSimple(profit_assetId, val: profit_amount, lbl: "Profit:");

      List<Map<String, dynamic>> assets = List.empty(growable: true);
      List<Map<String, String>> pools = List.empty(growable: true);

      for (var i in tx["stateChanges"]["invokes"]) {
        String dapp = i["dApp"];
        String func = i["call"]["function"];
        if (func != "w") {
          // print("--> ${i}");
          List<dynamic> payments = i["payment"] ?? List.empty(growable: true);
          if (payments.isNotEmpty) {
            String assetId = payments[0]["assetId"] ?? "WAVES";
            final amount = payments[0]["amount"];
            assets.add({"assetId": assetId, "amount": amount});
          }
          if (dapp != "3PLoX5yufZz9jRahL1CVVRAXq8VpUmXBKLK") {
            if (dapp == "3P68zNiufsu1viZpu1aY3cdahRRKcvV5N93") {
              var invs = i["stateChanges"]["invokes"];
              var resultMap = invs.firstWhere((element) => element["call"]["function"] == "calculateAmountOutForSwapAndSendTokens", orElse: () => null);
              pools.add({"pool": resultMap != null ? resultMap["dApp"] : "unknown", "type": "wx"});
            } else {
              pools.add({"pool": dapp, "type": blocksProvider.getPoolType(dapp)});
            }
          }
        }
      }
      List<Widget> payList = assets.map((e) => assetBuilderSimple(e["assetId"], val: e["amount"])).toList();
      // payList.add(assetBuilderSimple(profit_assetId, val: out_amount));
      child = Container(width: 600, height: 600, child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // profit,
          Divider(),
          Text("Assets:"),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: payList,),
          Divider(),
          Text("Pools:"),
          ListView.builder(
              shrinkWrap: true,
              itemCount: pools.length,
              itemBuilder: (context, index) {
                String pool_adr = pools[index]["pool"] ?? "undefined";
                String? type = pools[index]["type"];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinkToAddress(label: "$pool_adr ($type)", val: pool_adr, alias: false, color: Colors.white70,),
                    IconButton(onPressed: () {copyToClipboard(pool_adr);},
                        icon: Icon(Icons.copy, size: iconSize,))
                  ],
                );
              }),
        ],
      ),);
    }
    return IconButton(
        icon: Icon(Icons.list_alt_rounded, size: iconSize,),
        onPressed: () {showDialog(context: context,
            builder: (context) {
              return MyDialog(child: child, iconSize: iconSize);
            });
        }
    );
  }
}

class AssetsCell extends StatelessWidget {
  final Map<String, dynamic> tx;

  const AssetsCell({Key? key, required this.tx}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconSize = getLastFontSize();
    final type = tx["type"];
    if (type == 7 || (type == 16 && swappers.contains(tx["dApp"]) || (type == 16 && byFunc(tx["call"]["function"])))) {
      // print(tx);
      tx["additional"] = <String, dynamic>{};
      tx["additional"]["fail"] = false;
      Map<String, dynamic> p = parseTransactionType(tx, true);
      Map<String, double> transfers = {};
      final exop = p['exchPriceAsset'] == " " ? false : true;
      Map<String, double> payment = p['payment'];
      if (type == 16 && tx["dApp"] == wxSwap) {
        for (var i in tx["stateChanges"]["invokes"]) {
          final func = i["call"]["function"];
          if (func == "calculateAmountOutForSwapAndSendTokens") {
            var trsf = i["stateChanges"]["transfers"];
            for (var t in trsf) {
              if (t["address"] == tx["sender"]) {
                transfers = {t["asset"] ?? "WAVES": t["amount"]};
              }
            }
          }
        }
      } else {
        transfers = p["transfers"];
      }
      List<Widget> payList = payment.entries.map((e) => assetBuilder(e.key, e.value, exop, p["exchPriceAsset"], "in", null)).toList();
      List<Widget> inList = transfers.entries.map((e) => assetBuilder(e.key, e.value, exop, p["exchPriceAsset"], "out", null)).toList();
      return SizedBox(width: 300, height: 70,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            payList.isNotEmpty ? Expanded(child: OutWidget(payList: payList,shorted: true,)) : Container(),
            transfers.isNotEmpty ? Expanded(child: InWidget(income: inList, shorted: true,)) : Container()
          ],
        ),
      );
    }
    return Container();
  }
}


class AssetName extends StatelessWidget {
  final id;
  const AssetName({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Asset>(
        future: fetchAssetInfo(id),
        builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
      return Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasData) {
        final asset = snapshot.data;
        return Text(" ${asset!.name}");
      } else {
        return Text("No Data");
      }
        });
  }
}


