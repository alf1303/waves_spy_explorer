import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/chart_item.dart';


class PuzzleChart extends StatefulWidget {
  PuzzleChart({Key? key, required this.data, required this.gridSize}) : super(key: key);
  List<ChartItem> data;
  double gridSize;

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
    List<ChartItem> tmplist = [...widget.data];
    tmplist.sort((a, b) => a.value.compareTo(b.value));
    maxY = tmplist.last.value;
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
    if (value < widget.data.length && value%2 == 0) {
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
    final fontSize = getLastFontSize();
    final style = TextStyle(
      color: const Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
    );
    String text;
    if(value.toInt()%widget.gridSize == 0) {
      text = value.toInt().toString();
    } else {
      return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: widget.gridSize,
        verticalInterval: 5,
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
            reservedSize: 90,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: widget.data.length.toDouble() - 1,
      minY: 0,
      maxY: maxY*1.2,
      lineBarsData: [
        LineChartBarData(
          spots: getFlSpotsFromList(),
          isCurved: true,
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


