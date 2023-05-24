import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waves_spy/src/charts/puzzle/eagle_earnings.dart';
import 'package:waves_spy/src/charts/puzzle/puzzle_burn.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/main_page.dart';
import 'package:waves_spy/src/models/chart_item.dart';
//https://script.google.com/macros/s/AKfycbzPF4gGSCKDedr_WVB9xGGG8V-rkYtEyU87CtZr8TriBTd_JQhoi61j8uyh_6_k-kI/exec
import 'charts_helper.dart';
import 'puzzle_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PuzzleEarnings extends StatelessWidget {
  PuzzleEarnings({Key? key, this.showBar}) : super(key: key);
  bool? showBar;
  static const routeName = "puzzle_earnings";

  @override
  Widget build(BuildContext context) {
    bool showBar_t = showBar ?? true;
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    return Scaffold(
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
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyan), ),
                  child: Text("Eagle Chart", style: TextStyle(fontSize: fontSize*0.8, color: Colors.cyanAccent),),
                  onPressed: () {
                    Navigator.of(context).pushNamed(EagleEarnings.routeName);
                  },
                ),
              ),
              // SizedBox(width: 10,),
              // SizedBox(
              //   height: fontSize*2,
              //   child: OutlinedButton(
              //     style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyan), ),
              //     child: Text("Burn Machine", style: TextStyle(fontSize: fontSize*0.8, color: Colors.cyanAccent),),
              //     onPressed: () {
              //       Navigator.of(context).pushNamed(PuzzleBurn.routeName);
              //     },
              //   ),
              // ),
              const SizedBox(width: 10,),
              Expanded(child: Text("Puzzle Chart", style: TextStyle(fontSize: fontSize*1.1, fontWeight: FontWeight.bold),)),
            ],
          ),
        ),
      ) : null,
      body: Center(child: FutureBuilder<dynamic>(
        future: loadChartsData("puzzle"),
        builder: (context, snapshot) {
          Widget widget;
          if(snapshot.hasData) {
            double sum = 0;
            for (ChartItem element in snapshot.data!) {
              sum += element.value;
            }
            DateTime firstDate = DateTime.now();
            if(snapshot.data!.length > 0) {
              firstDate = snapshot.data!.first.date;
            }
            DateTime curDate = DateTime.now();
            int diff = curDate.subtract(Duration(days: 1)).difference(firstDate).inDays;
            widget = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Total rewards for Puzzle staking for $diff days: ${sum.toStringAsFixed(2)} USDN", style: TextStyle(fontSize: fontSize),),
                Expanded(child: PuzzleChart(data: snapshot.data!, gridSize: 200, full: false,)),
              ],
            );
          } else if (snapshot.hasError) {
            widget = Text("Some error_5: " + snapshot.error.toString(), style: TextStyle(fontSize: fontSize),);
          } else {
            widget = CircularProgressIndicator();
          }
          return widget;
        },
      )),
    );
  }
}
