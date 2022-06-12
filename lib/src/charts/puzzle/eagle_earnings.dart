import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            InkWell(
              radius: 15,
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(MainPage.mainPageRoute, (route) => false);
              },
              child: Row(children: [
                SizedBox(height: 35, child: Image.asset('assets/images/logo.png', fit: BoxFit.scaleDown,)),
                Text(AppLocalizations.of(context)!.headerTitle + "     ", style: TextStyle(fontSize: 14),),
              ],),
            ),
            const SizedBox(width: 10,),
            const Expanded(child: Text("Aggregator Earnings")),
          ],
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
            int diff = curDate.difference(firstDate).inDays;
            double oneEagleEarning = sum/77/diff;
            widget = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Total rewards for Eagles staking for $diff days: ${sum.toStringAsFixed(2)} USDN", style: TextStyle(fontSize: 16),),
                Text("~ ${oneEagleEarning.toStringAsFixed(2)} USDN/day for 1 Early Eagle, ${(sum/77).toStringAsFixed(2)} USDN total"),
                Expanded(child: PuzzleChart(data: snapshot.data!, gridSize: 2.5,)),
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
