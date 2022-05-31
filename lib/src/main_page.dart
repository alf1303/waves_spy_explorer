import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/input_widget.dart';
import 'package:waves_spy/src/widgets/main_area.dart';
import 'package:waves_spy/src/widgets/other/progress_bar.dart';
import 'package:waves_spy/src/widgets/transaction_details.dart';
import 'package:waves_spy/src/widgets/transactions/transactions_list.dart';

const String version = "v_1.0.0     ";
final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

class MainPage extends StatelessWidget {
  const MainPage({Key? key, this.address}) : super(key: key);
  final address;
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: messengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(height: 35, child: Image.asset('assets/images/logo.png', fit: BoxFit.scaleDown,)),
                    SelectableText(AppLocalizations.of(context)!.headerTitle + "     "),
                    Expanded(child: InputWidget(address: address)),
                  ],
                ),
              ),
              Text(version, style: TextStyle(fontSize: 10),)
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
      ),
    );
  }
}


