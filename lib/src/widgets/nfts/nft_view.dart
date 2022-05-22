import 'dart:html';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/models/nft.dart';
import 'package:waves_spy/src/providers/transaction_details_provider.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waves_spy/src/styles.dart';

class NftView extends StatelessWidget {
  const NftView({Key? key, required this.nft}) : super(key: key);

  final Nft nft;

  void showDetails() {
    final _transactionDetailsProvider = TransactionDetailsProvider();
    _transactionDetailsProvider.setTransaction(nft.data);
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  
  String getUrl() {
    String res = "https://puzzlemarket.org/nft/${nft.data["assetId"]}";
    
    if(nft.data["name"].toString().contains("DUCK")) {
      res = "https://wavesducks.com/duck/${nft.data["assetId"]}";
    }
    if(nft.data["name"].toString().contains("BABY")) {
      res = "https://wavesducks.com/duckling/${nft.data["assetId"]}";
    }
    if(nft.data["name"].toString().contains("ART")) {
      res = "https://wavesducks.com/item/${nft.data["assetId"]}";
    }
    
    return res;
  }

  Future<void> _launchInBrowser() async {
    final Uri url =
    Uri(scheme: 'https', host: 'wavesducks.com', path: 'portfolio/3PAtzncjJGWRpCtkR55wAzcfZ9fubMeA4JU');
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    String link = getUrl();
    String farmInfo = nft.isFarming ? "(staked, ${nft.farmingPower}%)" : "";
    return InkWell(
      hoverColor: hoverColor,
      onTap: showDetails,
      child: Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Row(
          children: [
            SizedBox(width: 300, child: Text("${nft.data["name"]} $farmInfo", style: TextStyle(color: nft.isFarming ? Colors.greenAccent : Colors.white),)),
            SizedBox(width: 450, child: Row(
              children: [
                Tooltip(
                  message: link,
                  child: RichText(
                    text: TextSpan(
                      style: link.isNotEmpty ? const TextStyle(color: Colors.cyan, decoration: TextDecoration.underline, decorationThickness: 2) : null,
                      text: nft.data["assetId"],
                      recognizer: TapGestureRecognizer()..onTap = () async {
                        await _launchURL(link);
                      }
                    ),
                  ),
                ),
                Expanded(child: Container(),)
              ],
            )),
            SizedBox(child: SelectableText("${getAddrName(nft.data["issuer"])} (${nft.data["issuer"]})"))
          ],
        ),
      ),
    );
  }
}
