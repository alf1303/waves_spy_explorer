import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waves_spy/src/charts/puzzle/puzzle_earnings.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/main_page.dart';
import 'package:waves_spy/src/models/chart_item.dart';
//https://script.google.com/macros/s/AKfycbzPF4gGSCKDedr_WVB9xGGG8V-rkYtEyU87CtZr8TriBTd_JQhoi61j8uyh_6_k-kI/exec
import 'charts_helper.dart';
import 'puzzle_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EagleEarnings extends StatelessWidget {
  EagleEarnings({Key? key}) : super(key: key);

  static const routeName = "aggregator_earnings";

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(fontSize*3.5),
        child: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(// radius: 15,
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(MainPage.mainPageRoute, (route) => false);
                },
                child: Tooltip(
                  message: "go to ${AppLocalizations.of(context)!.headerTitle}",
                  child: Row(children: [
                    SizedBox(height: iconSize, child: Image.asset('assets/images/logo.png', fit: BoxFit.scaleDown,)),
                    Text(AppLocalizations.of(context)!.headerTitle + "     ", style: TextStyle(fontSize: fontSize),),
                  ],),
                ),
              ),
              const SizedBox(width: 10,),
              SizedBox(
                height: fontSize*2,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyan), ),
                  child: Text("View Puzzles Chart", style: TextStyle(fontSize: fontSize*0.8, color: Colors.cyanAccent),),
                  onPressed: () {
                    Navigator.of(context).pushNamed(PuzzleEarnings.routeName);
                  },
                ),
              ),
              SizedBox(width: 10,),
              Expanded(child: Text("Aggregator Earnings Chart", style: TextStyle(fontSize: fontSize*1.1, fontWeight: FontWeight.bold),)),
            ],
          ),
        ),
      ),
      body: Center(child: FutureBuilder<List<ChartItem>>(
        future: getEagleEarnings(),
        builder: (context, snapshot) {
          Widget widget;
          if(snapshot.hasData) {
            double sum = 0;
            for (ChartItem element in snapshot.data!) {
              sum += element.value;
              element.value = double.parse((element.value/77).toStringAsFixed(2));
            }
            DateTime firstDate = DateTime.now();
            if(snapshot.data!.isNotEmpty) {
              firstDate = snapshot.data!.first.date;
            }
            DateTime curDate = DateTime.now();
            int diff = curDate.subtract(Duration(days: 1)).difference(firstDate).inDays;
            // int diff = curDate.difference(firstDate).inDays;
            double oneEagleEarning = sum/77/diff;
            widget = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Total rewards for Eagles staking for $diff days: ${sum.toStringAsFixed(2)} USDN", style: TextStyle(fontSize: fontSize*1.3),),
                Text("~ ${oneEagleEarning.toStringAsFixed(2)} USDN/day for 1 Early Eagle, ${(sum/77).toStringAsFixed(2)} USDN total", style: TextStyle(fontSize: fontSize*1.3),),
                Expanded(child: PuzzleChart(data: snapshot.data!, gridSize: 2.5,)),
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
