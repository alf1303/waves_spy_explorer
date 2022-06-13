import 'dart:math';

import 'package:flutter/material.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_details_provider.dart';
import 'package:waves_spy/src/styles.dart';

import '../../models/asset.dart';

class AssetView extends StatelessWidget {
  const AssetView({Key? key, required this.asset}) : super(key: key);
  final AccAsset asset;

  void showDetails() {
    final _trDetailsProvider = TransactionDetailsProvider();
    _trDetailsProvider.setTransaction(asset.data);
    // print("Tap" + td);
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final textStyle = TextStyle(fontSize: fontSize);
    final width = getWidth(context);
    final isNarr = isNarrow(context);
    return InkWell(
      hoverColor: hoverColor,
      onTap: showDetails,
      child: Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Row(
          children: [
            SizedBox(width: width*0.19, child: Text(asset.asset!.name, style: textStyle)),
            SizedBox(width: width*0.11, child: SelectableText("${asset.amount/pow(10, asset.asset!.decimals)}", style: textStyle)),
            // SizedBox(width: width*0.05, child: Container()), //SelectableText("${asset.staked/pow(10, asset.asset!.decimals)}")),
            !isNarr ? SizedBox(width: width*0.06, child: Text(asset.asset!.reissuable ? "reissuable" : "", style: textStyle),) : Container(),
            // !isNarr ? SizedBox(width: width * 0.02, child: Text(asset.asset!.scripted ? "scripted" : "", style: textStyle),) : Container(),
            SizedBox(child: SelectableText(asset.asset!.id, style: textStyle)),
          ],
        ),
      ),
    );
  }
}
