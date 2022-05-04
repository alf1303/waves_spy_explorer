import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/input_widget.dart';
import 'package:waves_spy/src/widgets/main_area.dart';
import 'package:waves_spy/src/widgets/transactions/transactions_list.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(AppLocalizations.of(context)!.headerTitle + "     "),
            Expanded(child: InputWidget())
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Expanded(flex: 2, child: MainArea()),
                const VerticalDivider(width: 3, color: Colors.grey,),
                Expanded(flex: 1, child: Container())
              ],
              ),
            ),
          )
        ],
      ),
    );
  }
}


