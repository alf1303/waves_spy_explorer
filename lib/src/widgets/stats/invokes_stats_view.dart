import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/stats_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/other/custom_widgets.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

class InvokesStatsView extends StatelessWidget {
  const InvokesStatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _trProvider = TransactionProvider();
    final _filterProvider = FilterProvider();
    final fontSize = getFontSize(context);
    return Container(
      child: Consumer<StatsProvider>(
        builder: (context, model, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      LabeledTextNoScroll("addr: ", "${_trProvider.curAddr}, ", getAddrName(_trProvider.curAddr)),
                      LabeledTextNoScroll("from: ", "${getFormattedDate(_filterProvider.actualFrom)}, "),
                      LabeledTextNoScroll("to: ", "${getFormattedDate(_filterProvider.actualTo)}, "),
                    ],
                  )),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16),
                      children:[
                    TextSpan(text: "Calls:\n", style: TextStyle(color: Colors.white, fontSize: fontSize)),
                    TextSpan(children: getCallsList(model.calls))
                  ]),),
                )
              ),
            ],
          );
        },
      ),
    );
  }
}

List<TextSpan> getCallsList(Map<String, int> calls) {
  List<TextSpan> res = List.empty(growable: true);
  calls.forEach((key, value) {
    res.add(LblGroup(label: key, val: value.toString(), tab: "  ", newLine: true));
  });
  return res;
}
