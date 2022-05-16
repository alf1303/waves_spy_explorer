import 'dart:math';

import 'package:flutter/material.dart';
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
    return InkWell(
      hoverColor: hoverColor,
      onTap: showDetails,
      child: Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Row(
          children: [
            SizedBox(width: 250, child: Text(asset.asset!.name)),
            SizedBox(width: 150, child: SelectableText("${asset.amount/pow(10, asset.asset!.decimals)}")),
            SizedBox(width: 150, child: SelectableText("${asset.staked/pow(10, asset.asset!.decimals)}")),
            SizedBox(width: 70, child: Text(asset.asset!.reissuable ? "reissuable" : ""),),
            SizedBox(width: 70, child: Text(asset.asset!.scripted ? "scripted" : ""),),
            SizedBox(child: SelectableText(asset.asset!.id)),
          ],
        ),
      ),
    );
  }
}
