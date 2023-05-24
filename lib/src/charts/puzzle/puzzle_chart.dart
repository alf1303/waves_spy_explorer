import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/chart_item.dart';
import 'package:intl/intl.dart';


class PuzzleChart extends StatefulWidget {
  PuzzleChart({Key? key, required this.data, required this.gridSize, required this.full}) : super(key: key);
  List<ChartItem> data;
  double gridSize;
  bool full;

  @override
  _PuzzleChartState createState() => _PuzzleChartState();
}

class _PuzzleChartState extends State<PuzzleChart> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  double maxY = 0;

  @override
  void initState() {
    super.initState();
    maxY = getMaxValue();
  }

  double getMaxValue() {
    List<ChartItem> tmplist = [...widget.data];
    tmplist.sort((a, b) => a.value.compareTo(b.value));
    final max = tmplist.last.value;
    return max;
  }

  double getGridSize() {
    final max = getMaxValue();
    final gridSize = max/20;
    return gridSize;
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    return Container(
      padding: EdgeInsets.all(25),
      child: LineChart(
        mainData()
    ),);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.white70,
      // fontWeight: FontWeight.bold,
      fontSize: getLastFontSize()
    );
    Widget text;
    // print(value);
    String val = "";
    double tmpval = widget.data.length - value - 1;
    final module = widget.full ? 1 : !lastIsNarrow() ? 8 : 16;
    final bool startend = tmpval == 0 || tmpval == widget.data.length - 1;
    final bool others = tmpval < widget.data.length && tmpval%module == 0 && tmpval != widget.data.length - 2;
    bool flag = startend || others || widget.data.length < 60;
    if (flag) {
      DateTime date = widget.data[value.toInt()].date;
      String month = date.month.toString().length == 1 ? "0" + date.month.toString() : date.month.toString();
      String day = date.day.toString().length == 1 ? "0" + date.day.toString() : date.day.toString();
      val = "${date.year}-$month-$day";
    }
    text = RotatedBox(quarterTurns: 3, child: Text("$val", style: style,));
    // print(val);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    // print(value);
    final fontSize = getLastFontSize();
    final isNarr = lastIsNarrow();
    final style = TextStyle(
      color: const Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
    );
    String text;
    double module = !isNarr ? getGridSize() : getGridSize()*4;
    print("$module, $value");
    text = value.toStringAsFixed(2);
    // if (value > 1) {
    //   if(value.toInt()%module == 0) {
    //     text = value.toInt().toString();
    //   } else {
    //     return Container();
    //   }
    // } else {
    //   text = value.toStringAsFixed(2);
    // }
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          tooltipBgColor: const Color(0xff23b6e6),
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            return lineBarsSpot.map((lineBarSpot) {
              final ddd = widget.data[lineBarSpot.x.toInt()].date;
              String fddd = DateFormat('yyyy-MM-dd').format(ddd);
              return LineTooltipItem(
                "${fddd}\n${lineBarSpot.y} \$Puzzle",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: getGridSize(), // widget.gridSize,
        verticalInterval: widget.data.length > 100 ? 4 : 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.blueGrey,
            strokeWidth: 0.6,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.blueGrey,
            strokeWidth: 0.6,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: getLastFontSize()*6,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: getGridSize() > 1 ? getGridSize()*2 : getGridSize()*4,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: getLastFontSize()*4,
          ),
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: widget.data.length.toDouble() - 1,
      minY: 0,
      maxY: getMaxValue()*1.2,
      lineBarsData: [
        LineChartBarData(
          spots: getFlSpotsFromList(),
          isCurved: true,
          preventCurveOverShooting: true,
          preventCurveOvershootingThreshold: 1,
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }

  getFlSpotsFromList() {
    List<FlSpot> fllist = [];
    for (ChartItem el in widget.data) {
      FlSpot spot = FlSpot(widget.data.indexOf(el).toDouble(), el.value);
      // print("index: ${widget.data.indexOf(el)}");
      fllist.add(spot);
    }
    return fllist;
  }

}


