import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waves_spy/src/charts/puzzle/puzzle_earnings.dart';
import 'package:waves_spy/src/charts/puzzle/puzzle_burn.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/main_page.dart';
import 'package:waves_spy/src/models/chart_item.dart';
import 'package:waves_spy/src/providers/puzzle_provider.dart';
//https://script.google.com/macros/s/AKfycbzPF4gGSCKDedr_WVB9xGGG8V-rkYtEyU87CtZr8TriBTd_JQhoi61j8uyh_6_k-kI/exec
import 'charts_helper.dart';
import 'puzzle_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

TabController? puzzleTabController;
class EagleEarnings extends StatefulWidget {
  EagleEarnings({Key? key}) : super(key: key);

  static const routeName = "aggregator_earnings";

  @override
  State<EagleEarnings> createState() => _EagleEarningsState();
}

class _EagleEarningsState extends State<EagleEarnings> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    final puzzleProvider = PuzzleProvider();
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
                // height: fontSize*2,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyan), ),
                  child: Text("Puzzles Chart", style: TextStyle(fontSize: fontSize*0.8, color: Colors.cyanAccent),),
                  onPressed: () {
                    Navigator.of(context).pushNamed(PuzzleEarnings.routeName);
                  },
                ),
              ),
              SizedBox(width: 10,),
              SizedBox(
                // height: fontSize*2,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyan), ),
                  child: Text("Burn Machine", style: TextStyle(fontSize: fontSize*0.8, color: Colors.cyanAccent),),
                  onPressed: () {
                    Navigator.of(context).pushNamed(PuzzleBurn.routeName);
                  },
                ),
              ),
              SizedBox(width: 10,),
              Expanded(child: Text("Aggregator Earnings Chart", style: TextStyle(fontSize: fontSize*1.1, fontWeight: FontWeight.bold),)),
            ],
          ),
        ),
      ),
      body: Center(child: FutureBuilder<List<AggregatorItem>>(
        future: getEagleEarnings(),
        builder: (context, snapshot) {
          Widget widget;
          if(snapshot.hasData) {
            DateTime aniasStart = DateTime(2022, 06, 30);
            double sumEagle = 0;
            double sumAnia = 0;
            int lastEagleStaked = 0;
            int lastAniaStaked = 0;
            List<ChartItem> eagles = List.empty(growable: true);
            List<ChartItem> anias = List.empty(growable: true);
            // int totalStakedGenerics = aniasStaked + eaglesStaked*5;
            for (AggregatorItem el in snapshot.data!) {
              int totalStakedGenerics = el.aniasStaked + el.eaglesStaked*5;
              double val = el.value;
              double genericEarn = val/totalStakedGenerics;
              sumEagle += genericEarn*5*el.eaglesStaked;
              sumAnia += genericEarn*el.aniasStaked;
              eagles.add(ChartItem(date: el.date, value: double.parse((genericEarn*5).toStringAsFixed(2))));
              // element.value = double.parse((element.value/77).toStringAsFixed(2));
              lastEagleStaked = el.eaglesStaked;
              lastAniaStaked = el.aniasStaked;
              if(el.date.isAfter(aniasStart.subtract(const Duration(days: 0)))) {
                anias.add(ChartItem(date: el.date, value: double.parse((genericEarn).toStringAsFixed(2))));
              }
            }

            DateTime firstDate = DateTime.now();
            if(snapshot.data!.isNotEmpty) {
              firstDate = snapshot.data!.first.date;
            }
            DateTime curDate = DateTime.now();
            int diff = curDate.subtract(Duration(days: 0)).difference(firstDate).inDays;
            int diffAnia = curDate.subtract(Duration(days: 0)).difference(aniasStart).inDays;
            // int diff = curDate.difference(firstDate).inDays;
            double oneEagleEarning = sumEagle/lastEagleStaked/diff;
            double oneAniaEarning = sumAnia/lastAniaStaked/diffAnia;
            widget = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                    controller: puzzleTabController,
                    tabs: [
                      Padding(
                        padding: EdgeInsets.all(fontSize*0.8),
                        child: Text("Eagles", style: TextStyle(fontSize: fontSize),),
                      ),
                      Padding(
                        padding: EdgeInsets.all(fontSize*0.8),
                        child: Text("Bored Anias", style: TextStyle(fontSize: fontSize),),
                      )
                    ]
                ),
                Expanded(
                  child: TabBarView(
                    controller: puzzleTabController,
                    children: [
                      Column(
                        children: [
                          Text("Total rewards for Eagles staking for $diff days: ${sumEagle.toStringAsFixed(2)} USDN", style: TextStyle(fontSize: fontSize*1.3),),
                          Text("~ ${oneEagleEarning.toStringAsFixed(2)} USDN/day for 1 Early Eagle, ${(sumEagle/lastEagleStaked).toStringAsFixed(2)} USDN total", style: TextStyle(fontSize: fontSize*1.3),),
                          Text("Eagles staked quantity: $lastEagleStaked", style: TextStyle(fontSize: fontSize*1.3),),
                          Expanded(child: PuzzleChart(data: eagles, gridSize: 2.5, full: false,)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Total rewards for Bored Anias staking for $diffAnia days: ${sumAnia.toStringAsFixed(2)} USDN", style: TextStyle(fontSize: fontSize*1.3),),
                          Text("~ ${oneAniaEarning.toStringAsFixed(2)} USDN/day for 1 Bored Ania, ${(sumAnia/lastAniaStaked).toStringAsFixed(2)} USDN total", style: TextStyle(fontSize: fontSize*1.3),),
                          Text("Bored Anias staked quantity: $lastAniaStaked", style: TextStyle(fontSize: fontSize*1.3),),
                          Expanded(child: PuzzleChart(data: anias, gridSize: 0.1, full: false,)),
                        ],
                      ),
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

  @override
  void initState() {
    puzzleTabController = TabController(length: 2, vsync: this);
  }
}
