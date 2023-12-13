import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/multipool/multipool_provider.dart';
import 'package:waves_spy/src/multipool/widgets.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';


class Multipool_View extends StatelessWidget {
  const Multipool_View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InputArea(),
          Expanded(child: ResultArea())
        ],
      ),
    );
  }
}

class InputArea extends StatelessWidget {
  InputArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);

    TextEditingController stepsAmountController = TextEditingController();
    TextEditingController feeController = TextEditingController();
    return Consumer<MultipoolProvider>(
      builder: (context, model, child) {
        stepsAmountController.text = model.stepsAmount.toString();
        feeController.text = model.fee.toString();
        return Container(child:
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(children: [ // Fixed inputs
              Flexible(flex: 2, child: InputWidgetFilter(label: "stepsAmount", fontSize: fontSize, isNumeric: true, isInteger: true, onchanged: model.setStepsAmount, controller: stepsAmountController)),
              Flexible(flex: 2, child: InputWidgetFilter(label: "fee", fontSize: fontSize, isNumeric: true, isInteger: false, onchanged: model.setFee, controller: feeController)),
              Row(
                children: [
                  Text("use arbitrage"),
                  Checkbox(value: model.use_arb, onChanged: (newVal) {model.setUseArb(newVal);},),
                ],
              )
            ],),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ // List inputs
              Expanded(child: AssetList(inputList: model.initAssets, title: "Init data", type: "init")),
              Expanded(child: AssetList(inputList: model.rebalanceAssets, title: "Rebalance data", type: "rebalance"))
            ],),
          ),
            Padding(padding: EdgeInsets.only(top: 10, bottom: 5), child:
              OutlinedButton(
                child: model.isLoading ? CircularProgressIndicator() : Text("EMULATE"),
                onPressed: () async {
                  await Future.delayed(Duration(seconds: 1));
                  await model.makeRequest();
                },
              )
              ,)
        ],)
        );
      },
    );
  }
}

class ResultArea extends StatelessWidget {
  const ResultArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container( color: Colors.black,
      child: Center(
        child: Consumer<MultipoolProvider>(
          builder: (context, model, child)
    {
      return model.isLoading ? CircularProgressIndicator() : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: model.result["error"] == null ? Column(
              children: [
                model.result["main"] == null ? Text("Results") : ResultTable(table: model.result["main"]),
                model.result["details"] == null ? Container() : ResultList(tableset: model.result["details"]),
                model.result["dataStorage"] == null ? Container() : ResultData(dataList: model.result["dataStorage"])
              ],
            ) : Text("ERROR: ${model.result['error']}", style: TextStyle(fontSize: 30, backgroundColor: Colors.redAccent),),
          )
        ),
      );
    }
    ),
      )
    );
  }
}




