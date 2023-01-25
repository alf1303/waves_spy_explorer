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
  EagleEarnings({Key? key, this.tabNum}) : super(key: key);

  int? tabNum;

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
              // SizedBox(
              //   height: fontSize*2,
              //   child: OutlinedButton(
              //     style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyan), ),
              //     child: Text("Puzzles Chart", style: TextStyle(fontSize: fontSize*0.8, color: Colors.cyanAccent),),
              //     onPressed: () {
              //       Navigator.of(context).pushNamed(PuzzleEarnings.routeName);
              //     },
              //   ),
              // ),
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
              SizedBox(width: 10,),
              Expanded(child: Text("Puzzle World Charts", style: TextStyle(fontSize: fontSize*1.1, fontWeight: FontWeight.bold),)),
            ],
          ),
        ),
      ),
      body: Center(child: FutureBuilder<dynamic>(
        future: loadChartsData("aggregator"),
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
            int diffPuzzle = curDate.difference(puzzleProvider.puzzleData.first.date).inDays;
            double oneEagleEarning = sumEagle/lastEagleStaked/diff;
            double oneAniaEarning = sumAnia/lastAniaStaked/diffAnia;
            List<ChartItem> zoomedEagles = eagles;
            widget = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                    controller: puzzleTabController,
                    tabs: [
                      Padding(
                        padding: EdgeInsets.all(fontSize*0.8),
                        child: Text("EAGLES", style: TextStyle(fontSize: fontSize*1.1),),
                      ),
                      Padding(
                        padding: EdgeInsets.all(fontSize*0.8),
                        child: Text("BORED ANIAS", style: TextStyle(fontSize: fontSize*1.1),),
                      ),
                      Padding(
                        padding: EdgeInsets.all(fontSize*0.8),
                        child: Text("PUZZLES", style: TextStyle(fontSize: fontSize*1.1),),
                      ),
                      Padding(
                        padding: EdgeInsets.all(fontSize*0.8),
                        child: Text("BURN MACHINE", style: TextStyle(fontSize: fontSize*1.1),),
                      )
                    ]
                ),
                Expanded(
                  child: TabBarView(
                    controller: puzzleTabController,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: fontSize*0.3,),
                          SelectableText("Total rewards for Eagles staking for $diff days: ${sumEagle.toStringAsFixed(2)} USDN", style: TextStyle(fontSize: fontSize),),
                          SelectableText("~ ${oneEagleEarning.toStringAsFixed(2)} USDN/day for 1 Early Eagle, ${(sumEagle/lastEagleStaked).toStringAsFixed(2)} USDN total", style: TextStyle(fontSize: fontSize),),
                          SelectableText("Eagles staked quantity: ${puzzleProvider.lastEaglesStaked}", style: TextStyle(fontSize: fontSize),),
                          Expanded(
                            child: ChartView(data: eagles, gridSize: 5, full: false,)
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: fontSize*0.3,),
                          SelectableText("Total rewards for Bored Anias staking for $diffAnia days: ${sumAnia.toStringAsFixed(2)} USDN", style: TextStyle(fontSize: fontSize),),
                          SelectableText("~ ${oneAniaEarning.toStringAsFixed(2)} USDN/day for 1 Bored Ania, ${(sumAnia/lastAniaStaked).toStringAsFixed(2)} USDN total", style: TextStyle(fontSize: fontSize),),
                          SelectableText("Bored Anias staked quantity: ${puzzleProvider.lastAniasStaked}", style: TextStyle(fontSize: fontSize),),
                          Expanded(child: ChartView(data: anias, gridSize: 0.02, full: false,)),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: fontSize*0.3,),
                          SelectableText("Total rewards for Puzzle staking for $diffPuzzle days: ${puzzleProvider.getPuzzleEarningsSum().toStringAsFixed(2)} USDN", style: TextStyle(fontSize: fontSize),),
                          Expanded(child: ChartView(data: puzzleProvider.puzzleData, gridSize: 200, full: false,)),
                        ],
                      ),
                      // PuzzleEarnings(showBar: false,),
                      PuzzleBurn(showBar: false)
                    ],
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            widget = SelectableText("Some error_3: " + snapshot.error.toString(), style: TextStyle(fontSize: fontSize),);
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
    puzzleTabController = TabController(length: 4, vsync: this, initialIndex: widget.tabNum ?? 0);
  }
}

class ChartView extends StatelessWidget {
  final List<ChartItem> data;
  final double gridSize;
  final bool full;

  const ChartView({Key? key, required this.data, required this.gridSize, required this.full}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ChartItem> zoomedData = data;
    return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(onPressed: () {
                    setState(() {
                      zoomedData = data;
                    });
                  }, child: const Text("ALL")),
                  OutlinedButton(onPressed: () {
                    setState(() {
                      int len = data.length;
                      zoomedData = data.getRange(len-120, len).toList();
                    });
                  }, child: const Text("120D")),
                  OutlinedButton(onPressed: () {
                    setState(() {
                      int len = data.length;
                      zoomedData = data.getRange(len-30, len).toList();
                    });
                  }, child: const Text("30D")),
                  OutlinedButton(onPressed: () {
                    setState(() {
                      int len = data.length;
                      zoomedData = data.getRange(len-7, len).toList();
                    });
                  }, child: const Text("7D")),
                ],
              ),
              Expanded(child: PuzzleChart(data: zoomedData, gridSize: gridSize, full: full,)),
            ],
          );
        }
    );
  }
}
