import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waves_spy/src/charts/puzzle/puzzle_earnings.dart';
import 'package:waves_spy/src/charts/puzzle/puzzle_burn.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/main_page.dart';
import 'package:waves_spy/src/models/chart_item.dart';
import 'package:waves_spy/src/providers/puzzle_provider.dart';
//https://script.google.com/macros/s/AKfycbzPF4gGSCKDedr_WVB9xGGG8V-rkYtEyU87CtZr8TriBTd_JQhoi61j8uyh_6_k-kI/exec
import '../../styles.dart';
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
  List<AggregatorItem> aggrData = List.empty(growable: true);
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
      body: StatefulBuilder(
        builder: (context, setState) {
          print("setstate");
          return Center(child: FutureBuilder<dynamic>(
            future: _getAggregatorData(), //loadChartsData("aggregator"),
            builder: (context, snapshot) {
              Widget widget;
              if (snapshot.connectionState != ConnectionState.done) {
                widget = CircularProgressIndicator();
              }
              if(aggrData.isNotEmpty) {
                // print("dadadadad");
                DateTime aniasStart = DateTime(2022, 06, 30);
                double sumEagle = 0;
                double sumAnia = 0;
                int lastEagleStaked = 0;
                int lastAniaStaked = 0;
                List<ChartItem> eagles = List.empty(growable: true);
                List<ChartItem> anias = List.empty(growable: true);
                // int totalStakedGenerics = aniasStaked + eaglesStaked*5;
                for (AggregatorItem el in aggrData) {
                  int totalStakedGenerics = el.aniasStaked + el.eaglesStaked*5;
                  double val = el.value;
                  double genericEarn = val/totalStakedGenerics;
                  sumEagle += genericEarn*5*el.eaglesStaked;
                  sumAnia += genericEarn*el.aniasStaked;
                  eagles.add(ChartItem(date: el.date, value: double.parse((genericEarn*5).toStringAsFixed(6))));
                  // element.value = double.parse((element.value/77).toStringAsFixed(2));
                  lastEagleStaked = el.eaglesStaked;
                  lastAniaStaked = el.aniasStaked;
                  if(el.date.isAfter(aniasStart.subtract(const Duration(days: 0)))) {
                    anias.add(ChartItem(date: el.date, value: double.parse((genericEarn).toStringAsFixed(6))));
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("EAGLES", style: TextStyle(fontSize: fontSize*1.1),),
                                IconButton(
                                    onPressed: () async {
                                      await _getAggregatorData();
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.refresh)),
                                // refreshButton(() {puzzleProvider.refresh();}, "Refresh", fontSize),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(fontSize*0.8),
                            child: Text("BORED ANIAS", style: TextStyle(fontSize: fontSize*1.1),),
                          ),
                          Padding(
                            padding: EdgeInsets.all(fontSize*0.8),
                            child: Text("PUZZLES", style: TextStyle(fontSize: fontSize*1.1),),
                          ),
                          // Padding(
                          //   padding: EdgeInsets.all(fontSize*0.8),
                          //   child: Text("BURN MACHINE", style: TextStyle(fontSize: fontSize*1.1),),
                          // )
                        ]
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: puzzleTabController,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: fontSize*0.3,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PuzzleAlarm(fontSize),
                                  SelectableText(" Total rewards for Eagles staking for $diff days: ${sumEagle.toStringAsFixed(2)} Puzzle", style: TextStyle(fontSize: fontSize),),
                                ],
                              ),
                              SelectableText("~ ${oneEagleEarning.toStringAsFixed(2)} Puzzle/day for 1 Early Eagle, ${(sumEagle/lastEagleStaked).toStringAsFixed(2)} Puzzle total", style: TextStyle(fontSize: fontSize),),
                              SelectableText("Eagles staked quantity: ${puzzleProvider.lastEaglesStaked}", style: TextStyle(fontSize: fontSize),),
                              Expanded(
                                child: ChartView(data: eagles, gridSize: 5, full: false,)
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(height: fontSize*0.3,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PuzzleAlarm(fontSize),
                                  SelectableText(" Total rewards for Bored Anias staking for $diffAnia days: ${sumAnia.toStringAsFixed(2)} Puzzle", style: TextStyle(fontSize: fontSize),),
                                ],
                              ),
                              SelectableText("~ ${oneAniaEarning.toStringAsFixed(2)} Puzzle/day for 1 Bored Ania, ${(sumAnia/lastAniaStaked).toStringAsFixed(2)} Puzzle total", style: TextStyle(fontSize: fontSize),),
                              SelectableText("Bored Anias staked quantity: ${puzzleProvider.lastAniasStaked}", style: TextStyle(fontSize: fontSize),),
                              Expanded(child: ChartView(data: anias, gridSize: 0.02, full: false,)),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(height: fontSize*0.3,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PuzzleAlarm(fontSize),
                                  SelectableText(" Total rewards for Puzzle staking for $diffPuzzle days: ${puzzleProvider.getPuzzleEarningsSum().toStringAsFixed(2)} Puzzle", style: TextStyle(fontSize: fontSize),),
                                ],
                              ),
                              Expanded(child: ChartView(data: puzzleProvider.puzzleData, gridSize: 200, full: false,)),
                            ],
                          ),
                          // PuzzleEarnings(showBar: false,),
                          // PuzzleBurn(showBar: false)
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
          ));
        }
      ),
    );
  }

  Future<List<dynamic>>? _getAggregatorData() async {
    aggrData.clear();
    aggrData = await loadChartsData("aggregator");
    return aggrData;
  }

  @override
  void initState() {
    puzzleTabController = TabController(length: 3, vsync: this, initialIndex: widget.tabNum ?? 0);
  }
}

class ChartView extends StatelessWidget {
  final List<ChartItem> data;
  final double gridSize;
  final bool full;

  const ChartView({Key? key, required this.data, required this.gridSize, required this.full}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final puzzleProvider = PuzzleProvider();
    final lenlen = data.length;
    int period = lenlen;
    if (puzzleProvider.zoomDays != 0) {
      period = puzzleProvider.zoomDays;
    }
    List<ChartItem> zoomedData = data.getRange(lenlen-period, lenlen).toList();
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
                      puzzleProvider.zoomDays = 0;
                    });
                  }, child: const Text("ALL")),
                  OutlinedButton(onPressed: () {
                    setState(() {
                      int len = data.length;
                      zoomedData = data.getRange(len-120, len).toList();
                      puzzleProvider.zoomDays = 120;
                    });
                  }, child: const Text("120D")),
                  OutlinedButton(onPressed: () {
                    setState(() {
                      int len = data.length;
                      zoomedData = data.getRange(len-30, len).toList();
                      puzzleProvider.zoomDays = 30;
                    });
                  }, child: const Text("30D")),
                  OutlinedButton(onPressed: () {
                    setState(() {
                      int len = data.length;
                      zoomedData = data.getRange(len-7, len).toList();
                      puzzleProvider.zoomDays = 7;
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

Widget loadButton(funct, String text, fontSize) {
  return InkWell(
    onTap: funct,
    hoverColor: hoverColor,
    child: Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(border: Border.all(color: Colors.greenAccent), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: fontSize),),
    ),
  );
}

Widget PuzzleAlarm(fontSize) {
  return Tooltip(
    // decoration: BoxDecoration(color: Colors.grey),
    textStyle: TextStyle(fontSize: fontSize, color: Colors.black),
    message: "Till 22.02.2023 rewards were in XTN.\nChart values and numbers till that date are calculated\n"
        "by converting XTN. value to Puzzle,\nusing price from WX.Network for according date",
    child: const Icon(Icons.help_outline, color: Colors.yellowAccent,),
  );
}
