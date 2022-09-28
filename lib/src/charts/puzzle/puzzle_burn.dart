import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/charts/puzzle/eagle_earnings.dart';
import 'package:waves_spy/src/charts/puzzle/puzzle_earnings.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/main_page.dart';
import 'package:waves_spy/src/models/chart_item.dart';
import 'package:waves_spy/src/providers/puzzle_provider.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';
//https://script.google.com/macros/s/AKfycbzPF4gGSCKDedr_WVB9xGGG8V-rkYtEyU87CtZr8TriBTd_JQhoi61j8uyh_6_k-kI/exec
import 'charts_helper.dart';
import 'puzzle_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GlobalKey<ScaffoldMessengerState> messengerKeyPuz = GlobalKey<ScaffoldMessengerState>();
class PuzzleBurn extends StatelessWidget {
  PuzzleBurn({Key? key, this.showBar}) : super(key: key);

  bool? showBar;
  static const routeName = "puzzle_burn";

  @override
  Widget build(BuildContext context) {
    bool showBar_t = showBar ?? true;
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    return Scaffold(
      key: messengerKeyPuz,
      appBar: showBar_t ? PreferredSize(
        preferredSize: Size.fromHeight(fontSize*3.5),
        child: AppBar(
          title: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(MainPage.mainPageRoute, (route) => false);
                },
                child: Tooltip(
                  message: "go to ${AppLocalizations.of(context)!.headerTitle}",
                  child: Row(children: [
                    SizedBox(height: iconSize, child: Image.asset('assets/images/logo.png', fit: BoxFit.scaleDown,)),
                    Text(AppLocalizations.of(context)!.headerTitle + "     ", style: TextStyle(fontSize: fontSize)),
                  ],),
                ),
              ),
              SizedBox(width: 10,),
              SizedBox(
                height: fontSize*2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyan), ),
                      child: Text("Eagle Chart", style: TextStyle(fontSize: fontSize*0.8, color: Colors.cyanAccent),),
                      onPressed: () {
                        Navigator.of(context).pushNamed(EagleEarnings.routeName);
                      },
                    ),
                    const SizedBox(width: 10,),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyan), ),
                      child: Text("Puzzle Chart", style: TextStyle(fontSize: fontSize*0.8, color: Colors.cyanAccent),),
                      onPressed: () {
                        Navigator.of(context).pushNamed(PuzzleEarnings.routeName);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(child: Text("Puzzle Burn Machine Chart", style: TextStyle(fontSize: fontSize*1.1, fontWeight: FontWeight.bold),)),
            ],
          ),
        ),
      ) : null,
      body: Center(child: FutureBuilder<dynamic>(
        future: loadChartsData("burn"),
        builder: (context, snapshot) {
          final puzzleProvider = PuzzleProvider();
          Widget widget;
          if(snapshot.hasData) {
            List<ChartItem> daily = snapshot.data!["daily"]!.cast<ChartItem>();
            // List<DataItem> dapps = snapshot.data!["dapp"]!.cast<DataItem>();
            // List<DataItem> users = snapshot.data!["user"]!.cast<DataItem>();
            double sum = 0;
            for(ChartItem it in daily) {
              sum += it.value;
            }
            // final diff = daily.length;
            final diff = daily.last.date.difference(daily.first.date).inDays;
            widget = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: fontSize*0.3,),
                Text("Total Puzzles burned by Burn Machine for $diff days: ${sum.toStringAsFixed(2)} Puzzle", style: TextStyle(fontSize: fontSize),),
                Expanded(child: PuzzleChart(data: daily, gridSize: 2, full: true,)),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: AddressWidget(list: puzzleProvider.filteredDappList, label: "Pool address/name",)),
                      Expanded(child: AddressWidget(list: puzzleProvider.filteredUserList, label: "Trader address",))
                    ],
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            widget = Text("Some error_4: " + snapshot.error.toString(), style: TextStyle(fontSize: fontSize),);
          } else {
            widget = CircularProgressIndicator();
          }
          return widget;
        },
      )),
    );
  }
}

class AddressWidget extends StatelessWidget {
  const AddressWidget({Key? key, required this.list, required this.label}) : super(key: key);
  final List<DataItem> list;
  final String label;

  void addressChanged(str) {
    final puzzleProvider = PuzzleProvider();
    if(label == "Pool address/name") {
      puzzleProvider.changePoolName(str);
    } else {
      puzzleProvider.changeUserName(str);
    }
  }

  void clearAddress() {
    final puzzleProvider = PuzzleProvider();
    if(label == "Pool address/name") {
      puzzleProvider.clearPool();
    } else {
      puzzleProvider.clearUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    final isPortrt = isPortrait(context);
    final puzzleprovider = PuzzleProvider();
    return Consumer<PuzzleProvider>(builder: (context, model, child) {
      final ll = label == "Pool address/name" ? model.filteredDappList : model.filteredUserList;
      final addressController = TextEditingController();
      addressController.text = label == "Pool address/name" ? puzzleprovider.poolName : puzzleprovider.userName;
      addressController.selection = TextSelection.fromPosition(TextPosition(offset: addressController.text.length));
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: fontSize*0.3),
            child: SizedBox(
                height: fontSize*4,
                child: InputWidgetFilter(controller: addressController, onchanged: addressChanged, clearFunc: clearAddress, label: label, hint: "", fontSize: fontSize, iconSize: iconSize)),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
                primary: false,
                itemCount: ll.length,
                itemBuilder: (context, index) {
                  return AddrItem(item: ll[index], isPortrait: isPortrt);
                }),
          )
        ],
      );
    });
  }
}

class AddrItem extends StatelessWidget {
  const AddrItem({Key? key, required this.item, required this.isPortrait}) : super(key: key);
  final DataItem item;
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    // print(item.address);
    final fontSize = getFontSize(context);
    final width = getWidth(context);
    final style = TextStyle(fontSize: fontSize);
    final address = item.address;
    // final name = getAddrName(address);
    // final namestr = name.isEmpty ? "" : "($name)";
    // final s = "$address$namestr";
    final ind = address.indexOf("(");
    String a = address;
    String n = "";
    if(ind != -1) {
      a = address.substring(0, ind);
      n = address.substring(ind, address.length);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fontSize*0.6, vertical: fontSize*0.2),
      margin: EdgeInsets.symmetric(horizontal: fontSize*0.6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(fontSize*0.2)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SizedBox(
                width: width*0.3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: isPortrait ? n.isEmpty : true,
                      child: Expanded(
                        child: SelectableText(a, style: style,),
                      ),
                    ),
                    Expanded(child: LinkToAddress(val: a, label: n, alias: false, fontSize: fontSize*0.8, color: Colors.lightGreenAccent,))
                    // Expanded(child: LabeledText(label: n, value: a, name: "", colr: Colors.lightGreenAccent, addrLink: true, fontSize: fontSize))
                    // SelectableText(n, style: TextStyle(fontSize: fontSize*0.9, color: Colors.lightGreenAccent),),
                  ],
                )
            ),
          ),
          SelectableText(item.value.toString(), style: style,)
        ],
      ),
    );
  }
}

