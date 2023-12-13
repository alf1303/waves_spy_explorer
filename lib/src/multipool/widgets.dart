import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/multipool/multipool_provider.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/other/custom_widgets.dart';

Widget assetsSelect(double fontSize, List<String> inputs, void Function(String?)? onChangedDirection) {
  return MyToolTip(
    message: "Select asset",
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton(
          items: inputs.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(items, style: TextStyle(fontSize: fontSize),),
            );
          }).toList(),
          value: inputs[0],
          isDense: true,
          onChanged: onChangedDirection),
    ),
  );
}

class AssetList extends StatelessWidget {
  AssetList({Key? key,  required this.inputList, required this.title, required this.type}) : super(key: key);
  List<Map<String, dynamic>> inputList;
  final title;
  final type;

  @override
  Widget build(BuildContext context) {
    final multipoolProvider = MultipoolProvider();
    return Container(
      margin: EdgeInsets.all(30),
      // width: 400,
      // height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title),
              IconButton(
                  onPressed: () {
                    multipoolProvider.addItem(type);
                  },
                  icon: const Icon(Icons.add_box_outlined))
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: inputList.length,
            itemBuilder: (context, index) {
              return AssetRow(item: inputList[index], type: type, index: index);
    }
    ),
        ],
      )
    );
  }
}


class AssetRow extends StatelessWidget {
  AssetRow({Key? key, required this.item, required this.type, required this.index}) : super(key: key);
  Map<String, dynamic> item;
  final type;
  final multipoolProvider = MultipoolProvider();
  final index;

  removeItem() {
    multipoolProvider.removeItem(type, item["assetId"], index);
  }

  setAmount() {
    multipoolProvider.setAmount(item["assetId"], item["amountController"].text, type);
  }

  setWeight() {
    multipoolProvider.setWeight(item["assetId"], item["weightController"].text, type);
  }

  setAsset(String? newVal) {
    multipoolProvider.setAsset(newVal!, type, index);
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);

    String assetId = item["assetId"];
    int amount = item["amount"];
    int weight = item["weight"];
    final amountController = item["amountController"];
    final weightController = item["weightController"];
    amountController.selection = TextSelection.fromPosition(TextPosition(offset: amountController.text.length));
    weightController.selection = TextSelection.fromPosition(TextPosition(offset: weightController.text.length));
    return Container(child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: assetId,
          onChanged: (String? newValue) {
            setAsset(newValue);
          },
          items: multipoolProvider.assets.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
        ),
        Expanded(child: InputWidgetFilter(controller: amountController, isNumeric: true, isInteger: false, fontSize: fontSize, label: "Amount", submit: false, onchanged: (val) => setAmount())),
        Expanded(child: InputWidgetFilter(controller: weightController, isNumeric: true, isInteger: true, fontSize: fontSize, label: "Weight", submit: false, onchanged: (val) => setWeight())),
        IconButton(
            onPressed: () {
              removeItem();
            },
            icon: const Icon(Icons.remove_circle_outline))
        // Text(weight.toString())
      ],
    ),);
  }
}

class ResultList extends StatelessWidget {
  ResultList({Key? key, required this.tableset}) : super(key: key);
  List<dynamic> tableset;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: tableset.length,
        itemBuilder: (context, index) {
          return ResultTable(table: tableset[index]);
        });
  }
}


class ResultTable extends StatelessWidget {
  ResultTable({Key? key, required this.table}) : super(key: key);
  List<dynamic> table;

  @override
  Widget build(BuildContext context) {
    final headers = table[0].cast<String>();
    final data = table.getRange(1, table.length).toList();
    return Align(
      alignment: Alignment.centerLeft,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.white30),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DataTable(headingRowColor: MaterialStateProperty.all<Color>(Colors.white24),
            border: TableBorder.symmetric(inside: BorderSide(color: Colors.white30, width: 2), outside: BorderSide(color: Colors.white60, width: 3)),
            dividerThickness: 0,
              columns: headers.map<DataColumn>((e) {
                return DataColumn(label: Text((e is int || e is double) ? e.toString() : e));
              }).toList(),
              rows: data.map<DataRow>((row) {
                return DataRow(cells: row.map<DataCell>((dd) {
                  return DataCell(Text((dd is int || dd is double) ? dd.toString() : dd));
                }).toList());
              }).toList()),
        ),
      ),
    );
  }
}

class ResultData extends StatelessWidget {
  const ResultData({Key? key, required this.dataList}) : super(key: key);
  final dataList;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Multipool data storage:", style: TextStyle(fontSize: 20, backgroundColor: Colors.white30),),
          ListView.builder(
            shrinkWrap: true,
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                var item = dataList[index];
                return Row(
                  children: [
                    Text("${item['key']}:  ", style: TextStyle(fontSize: 18,),),
                    Text(item["value"].toString(), style: TextStyle(fontSize: 20, backgroundColor: Colors.white30),)
                  ],
                );
              }),
        ],
      ),
    );
  }
}

