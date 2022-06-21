import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/app.dart';
import 'package:waves_spy/src/charts/puzzle/puzzle_earnings.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/label_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/input_widget.dart';
import 'package:waves_spy/src/widgets/main_area.dart';
import 'package:waves_spy/src/widgets/other/custom_widgets.dart';
import 'package:waves_spy/src/widgets/other/progress_bar.dart';
import 'package:waves_spy/src/widgets/transaction_details.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';
import 'package:waves_spy/src/widgets/transactions/transactions_list.dart';
import 'package:fluttertoast/fluttertoast.dart';


import 'charts/puzzle/eagle_earnings.dart';

const String version = "v_1.0.3     ";
final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();
class MainPage extends StatelessWidget {
  const MainPage({Key? key, this.address}) : super(key: key);
  static const mainPageRoute = "main";
  final address;
  @override
  Widget build(BuildContext context) {
    final transactionProvider = TransactionProvider();
    final height = getHeight(context);
    final width = getWidth(context);
    final isMob = isPortrait(context);
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    return ScaffoldMessenger(
      key: messengerKey,
      child: isMob? MobilePage() : Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(fontSize*3.5),
          child: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(height: iconSize, child: Image.asset('assets/images/logo.png', fit: BoxFit.scaleDown,)),
                      SelectableText(AppLocalizations.of(context)!.headerTitle + "     ", style: TextStyle(fontSize: fontSize),),
                      MyToolTip(
                        message: "Show contracts",
                        child: IconButton(
                            icon: Icon(Icons.list_alt_rounded, size: iconSize,),
                            onPressed: () {
                              showDialog(context: context,
                                  builder: (context) {
                                    return MyDialog(
                                      title: "Addresses:",
                                        child: getMainAddresses(),
                                        iconSize: iconSize);
                                  });
                            }
                        ),
                      ),
                      Expanded(
                        child: Consumer<LabelProvider>(
                            builder: (context, model, child) {
                              return Row(
                                children: [
                                  InputWidget(address: address),
                                  model.isAddressPresent ? Text(getAddrName(transactionProvider.curAddr), style: TextStyle(fontSize: fontSize),) : Container()
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      height: fontSize*2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyan), ),
                        child: Text("Puzzles Chart", style: TextStyle(fontSize: fontSize*0.9, color: Colors.cyanAccent),),
                        onPressed: () {
                          Navigator.of(context).pushNamed(PuzzleEarnings.routeName);
                        },
                      ),
                    ),
                    const SizedBox(width: 10,),
                    SizedBox(
                      height: fontSize*2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyan), ),
                        child: Text("Eagle Chart", style: TextStyle(fontSize: fontSize*0.9, color: Colors.cyanAccent),),
                        onPressed: () {
                          Navigator.of(context).pushNamed(EagleEarnings.routeName);
                        },
                      ),
                    ),
                    const LinkToAnyAddress(val: "https://t.me/+mCNtrBJqEHA1ZGQy", label: "Telegram group", color: Colors.cyan,),
                    GestureDetector(
                        onLongPress: addPrvtAddr,
                        child: Text(version, style: TextStyle(fontSize: fontSize*0.6),)),
                  ],
                )
              ],
            ),

          ),
        ),
        body: Column(
          children: [
            const MyProgressBar(label: "main"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: const [
                  Expanded(flex: 2, child: MainArea()),
                  VerticalDivider(width: 3, color: Colors.grey,),
                  Expanded(flex: 1, child: TransactionDetails())
                ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget getMainAddresses() {
  final fontSize = getLastFontSize();
  final style = TextStyle(fontSize: fontSize);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AddrWidget(text: "WD - Incubator: 3PEktVux2RhchSN63DsDo4b4mz4QqzKSeDv", style: style),
        AddrWidget(text: "WD - Breeder: 3PDVuU45H7Eh5dmtNbnRNRStGwULA7NY6Hb", style: style),
        AddrWidget(text: "WD - Market: 3PEBtiSVLrqyYxGd76vXKu8FFWWsD1c5uYG", style: style),
        AddrWidget(text: "WD - Farming: 3PAETTtuW7aSiyKtn9GuML3RgtV1xdq1mQW", style: style),
        AddrWidget(text: "WD - Rebirth: 3PCC6fVHNa6289DTDmcUo3RuLaFmteZZsmQ", style: style),
        AddrWidget(text: "WD - Game: 3PR87TwfWio6HVUScSaHGMnFYkGyaVdFeqT", style: style),
        AddrWidget(text: "WD - Ducklings: 3PKmLiGEfqLWMC1H9xhzqvAZKUXfFm8uoeg", style: style),
        AddrWidget(text: "WD - Eggs Treasury: 3PLkyPruTTLt2JfeHekaz7vHG2CWyBnwXDM", style: style),
        AddrWidget(text: "PUZZLE Aggregator: 3PGFHzVGT4NTigwCKP1NcwoXkodVZwvBuuU", style: style),
        AddrWidget(text: "SWOP.FI Router: 3P4v7QaMk6us7PdxSuoR5LmZmemv5ruD6oj", style: style),
        AddrWidget(text: "KEEPER Aggregator: 3P5UKXpQbom7GB2WGdPG5yGQPeQQuM3hFmw", style: style),
      ]
    );
}

Widget AddrWidget({required String text, required TextStyle style}) {
  final spaceIndex = text.lastIndexOf(" ");
  final fontSize = getLastFontSize();
  final addr = text.substring(spaceIndex, text.length);
  final label = text.substring(0, spaceIndex);

  const copy = "copy";
  const copied = "copied";
  bool isCopied = false;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      // SelectableText(text, style: style,),
      SelectableText.rich(
        TextSpan(
          children: [
            TextSpan(text: label, style: TextStyle(color: Colors.cyanAccent)),
            TextSpan(text: addr)
          ]
        ),
        style: TextStyle(fontSize: fontSize),
      ),
      StatefulBuilder(
          builder: (context, setStat) {
            return TextButton(onPressed: () {
              Clipboard.setData(ClipboardData(text: addr));
              setStat(() {
                isCopied = true;
              });
              // showSnackMsg("copied");
            },
                child: Text(isCopied ? copied : copy, style: TextStyle(fontSize: fontSize, color: isCopied ? Colors.orange : null)),);
          })
    ],
  );
}


