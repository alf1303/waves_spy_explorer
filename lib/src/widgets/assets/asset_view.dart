import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/asset.dart';

class AssetView extends StatelessWidget {
  const AssetView({Key? key, required this.asset}) : super(key: key);
  final AccAsset asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Row(
        children: [
          SizedBox(width: 250, child: SelectableText(asset.asset!.name)),
          SizedBox(width: 150, child: SelectableText("${asset.amount/pow(10, asset.asset!.decimals)}")),
          SizedBox(width: 150, child: SelectableText("${asset.staked/pow(10, asset.asset!.decimals)}")),
          SizedBox(width: 70, child: Text(asset.asset!.reissuable ? "reissuable" : ""),),
          SizedBox(width: 70, child: Text(asset.asset!.scripted ? "scripted" : ""),),
          SizedBox(child: SelectableText(asset.asset!.id)),
        ],
      ),
    );
  }
}
