import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/stats_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

class DuckStatsView extends StatelessWidget {
  const DuckStatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _trProvider = TransactionProvider();
    final _filterProvider = FilterProvider();
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
                child: Container(color: Colors.yellow,)
              ),
            ],
          );
        },
      ),
    );
  }
}
