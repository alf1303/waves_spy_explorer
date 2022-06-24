import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waves_spy/src/charts/puzzle/eagle_earnings.dart';
import 'package:waves_spy/src/charts/puzzle/puzzle_earnings.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/main_page.dart';
import 'package:waves_spy/src/models/chart_item.dart';
//https://script.google.com/macros/s/AKfycbzPF4gGSCKDedr_WVB9xGGG8V-rkYtEyU87CtZr8TriBTd_JQhoi61j8uyh_6_k-kI/exec
import 'charts_helper.dart';
import 'puzzle_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PuzzleBurn extends StatelessWidget {
  PuzzleBurn({Key? key}) : super(key: key);

  static const routeName = "puzzle_burn";

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    return Scaffold(
      appBar: PreferredSize(
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
                      child: Text("View Eagle Chart", style: TextStyle(fontSize: fontSize*0.8, color: Colors.cyanAccent),),
                      onPressed: () {
                        Navigator.of(context).pushNamed(EagleEarnings.routeName);
                      },
                    ),
                    const SizedBox(width: 10,),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyan), ),
                      child: Text("View Puzzle Chart", style: TextStyle(fontSize: fontSize*0.8, color: Colors.cyanAccent),),
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
      ),
      body: Center(child: FutureBuilder<Map<String, List<dynamic>>>(
        future: getBurnMachine(),
        builder: (context, snapshot) {
          Widget widget;
          if(snapshot.hasData) {
            List<ChartItem> daily = snapshot.data!["daily"]!.cast<ChartItem>();
            List<DataItem> dapps = snapshot.data!["dapp"]!.cast<DataItem>();
            List<DataItem> users = snapshot.data!["user"]!.cast<DataItem>();
            double sum = 0;
            for(ChartItem it in daily) {
              sum += it.value;
            }
            final diff = daily.length;
            widget = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Total Puzzles burned by Burn Machine for $diff days: ${sum.toStringAsFixed(2)} Puzzle", style: TextStyle(fontSize: fontSize*1.3),),
                Expanded(child: PuzzleChart(data: daily, gridSize: 2, full: true,)),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: AddressWidget(list: dapps)),
                      Expanded(child: AddressWidget(list: users))
                    ],
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            widget = Text("Some error: " + snapshot.error.toString(), style: TextStyle(fontSize: fontSize),);
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
  const AddressWidget({Key? key, required this.list}) : super(key: key);
  final List<DataItem> list;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("${list.length}"));
  }
}
