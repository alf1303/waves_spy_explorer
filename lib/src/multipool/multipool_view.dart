import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/multipool/multipool_provider.dart';
import 'package:waves_spy/src/multipool/widgets.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/other/custom_widgets.dart';


class Multipool_View extends StatelessWidget {
  const Multipool_View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(flex: 2, child: InputArea()),
          VerticalDivider(width: 2,),
          // Flexible(flex: 5, child: Text("results"))
          Flexible(flex: 5, child: ResultArea())
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
        return Container(
            margin: EdgeInsets.all(5),
            child:
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
            Flexible(flex: 2, child: InputWidgetFilter(label: "stepsAmount", fontSize: fontSize, isNumeric: true, isInteger: true, onchanged: model.setStepsAmount, controller: stepsAmountController)),
            Flexible(flex: 2, child: InputWidgetFilter(label: "poolFee", fontSize: fontSize, isNumeric: true, isInteger: false, onchanged: model.setFee, controller: feeController)),
            Flexible(
              child: Row(
                children: [
                  Text("  use arbitrage"),
                  Checkbox(activeColor: Colors.indigo, value: model.use_arb, onChanged: (newVal) {model.setUseArb(newVal);},),
                ],
              ),
            ),
            AssetList(inputList: model.initAssets, title: "Init data", type: "init"),
            AssetList(inputList: model.rebalanceAssets, title: "Rebalance data", type: "rebalance"),
            Padding(padding: EdgeInsets.only(top: 10, bottom: 5), child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.white24)),
                      child: model.isLoading ? CircularProgressIndicator() : Text("EMULATE", style: TextStyle(color: Colors.cyanAccent),),
                    onPressed: () async {
                      await Future.delayed(Duration(seconds: 1));
                      await model.makeRequest();
                    },
                  ),
                  MyToolTip(
                      message: "Fixed pool exchange any tokens 1:1, so any token price is 1\$.\n"
                          "Arbitrage bot is running after each stepRebalancing call.\n"
                          "USDT should be in composition, because it is taken as baseTokenId in emulation and is used by arbitrage bot",
                      child: Icon(Icons.help_outline, color: Colors.yellowAccent,))
                ],
              )
              ,)
          ],),
        )
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




