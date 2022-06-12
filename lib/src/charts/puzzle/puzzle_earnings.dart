import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waves_spy/src/main_page.dart';
import 'package:waves_spy/src/models/chart_item.dart';
//https://script.google.com/macros/s/AKfycbzPF4gGSCKDedr_WVB9xGGG8V-rkYtEyU87CtZr8TriBTd_JQhoi61j8uyh_6_k-kI/exec
import 'charts_helper.dart';
import 'puzzle_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PuzzleEarnings extends StatelessWidget {
  PuzzleEarnings({Key? key}) : super(key: key);

  static const routeName = "puzzle_earnings";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(MainPage.mainPageRoute, (route) => false);
              },
              child: Row(children: [
                SizedBox(height: 35, child: Image.asset('assets/images/logo.png', fit: BoxFit.scaleDown,)),
                Text(AppLocalizations.of(context)!.headerTitle + "     ", style: TextStyle(fontSize: 14)),
              ],),
            ),
            const SizedBox(width: 10,),
            const Expanded(child: Text("Puzzle Earnings")),
          ],
        ),
      ),
      body: Center(child: FutureBuilder<List<ChartItem>>(
        future: getPuzzleEarnings(),
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
            int diff = curDate.difference(firstDate).inDays;
            widget = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Total rewards for Puzzle staking for $diff days: ${sum.toStringAsFixed(2)} USDN", style: TextStyle(fontSize: 16),),
                Expanded(child: PuzzleChart(data: snapshot.data!, gridSize: 100,)),
              ],
            );
          } else if (snapshot.hasError) {
            widget = Text("Some error: " + snapshot.error.toString());
          } else {
            widget = CircularProgressIndicator();
          }
          return widget;
        },
      )),
    );
  }
}
