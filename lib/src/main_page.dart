import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/input_widget.dart';
import 'package:waves_spy/src/widgets/main_area.dart';
import 'package:waves_spy/src/widgets/other/progress_bar.dart';
import 'package:waves_spy/src/widgets/transaction_details.dart';
import 'package:waves_spy/src/widgets/transactions/transactions_list.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key, this.address}) : super(key: key);
  final address;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SelectableText(AppLocalizations.of(context)!.headerTitle + "     "),
            Expanded(child: InputWidget(address: address)),
          ],
        ),
      ),
      body: Column(
        children: [
          const MyProgressBar(label: "main"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: const [
                Expanded(flex: 2, child: MainArea()),
                VerticalDivider(width: 3, color: Colors.grey,),
                Expanded(flex: 1, child: TransactionDetails())
              ],
              ),
            ),
          )
        ],
      ),
    );
  }
}


