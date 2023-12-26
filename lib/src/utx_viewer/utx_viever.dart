import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/arb_blocks/blocks_provider.dart';
import 'package:waves_spy/src/arb_blocks/widgets.dart';
import 'package:waves_spy/src/charts/puzzle/eagle_earnings.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:waves_spy/src/main_page.dart';
import 'package:waves_spy/src/utx_viewer/utx_provider.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/input_widget.dart';

class UtxViever extends StatelessWidget {
  const UtxViever({Key? key}) : super(key: key);
  static const routeName = "utx_viewer";

  // var loadFrames() async{
  //   final utxProvider = UtxProvider();
  //   return utxProvider.getFrames();
  // }

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    final utxProvider = UtxProvider();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(fontSize*3.5),
        child: AppBar(
          title: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(MainPage.mainPageRoute, (route) => false);
                },
                child: Tooltip(
                  message: "go to ${AppLocalizations.of(context)!.headerTitle}",
                  child: Row(children: [
                    SizedBox(height: iconSize, child: Image.asset('assets/images/logo.png', fit: BoxFit.scaleDown,)),
                    Text("${AppLocalizations.of(context)!.headerTitle}     ", style: TextStyle(fontSize: fontSize)),
                  ],),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<UtxProvider>(
        builder: (context, model, child) {
          return FramesViewer();
    }),
    );
  }
}

class FramesViewer extends StatelessWidget {
  const FramesViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final utxProvider = UtxProvider();
    final tsController = TextEditingController(text: (utxProvider.fromTime).toString());
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(flex: 2, child: InputWidgetFilter(label: "timestamp", fontSize: fontSize, isNumeric: true, isInteger: false, onchanged: utxProvider.setTs, controller: tsController)),
            utxProvider.isLoading ? CircularProgressIndicator() :OutlinedButton(
                onPressed: () {
                  utxProvider.getFrames();
                },
                child: Text("LOAD")),
            OutlinedButton(
                onPressed: () {
                  utxProvider.prevFrame();
                },
                child: Text("PREV")),
            OutlinedButton(
                onPressed: () {
                  utxProvider.nextFrame();
                },
                child: Text("NEXT")),
            Flexible(flex: 6, child: Text("current: ${utxProvider.index}, total: ${utxProvider.frames.length}"))
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.white70),
              child: DataTable(
                  columns: const [
                    DataColumn(label: Text("STATUS")),
                    DataColumn(label: Text("DAPP")),
                    DataColumn(label: Text("TYPE")),
                    DataColumn(label: Text("FUNCTION")),
                    DataColumn(label: Text("SENDER")),
                    DataColumn(label: Text("ID")),
                    DataColumn(label: Text("HEIGHT")),
                    DataColumn(label: Text("TS")),
                  ],
                  dividerThickness: 2,
                  rows:
                  utxProvider.current.map<DataRow>((item) {
                    // print(item);
                    return DataRow(cells: [
                      DataCell(item["status"] == "true" ? Icon(Icons.check_rounded, color: Colors.green,) : item["status"] == "false" ? Icon(Icons.close, color: Colors.redAccent,) : Icon(Icons.device_unknown_outlined)),
                      DataCell(SelectableText(item["dapp"])),
                      DataCell(SelectableText(item["type"].toString())),
                      DataCell(SelectableText(item["function"])),
                      DataCell(SelectableText(item["sender"])),
                      DataCell(SelectableText(item["id"])),
                      DataCell(SelectableText(item["height"].toString())),
                      DataCell(SelectableText(item["timestamp"].toString()))
                    ]);
                  }).toList()
              ),
            ),
          ),
        )
      ],
    );
  }
}



