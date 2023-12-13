import 'package:flutter/material.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/main_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:waves_spy/src/multipool/multipool_view.dart';

class Multipool extends StatelessWidget {
  const Multipool({Key? key}) : super(key: key);
  static const routeName = "multipool";

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
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
      body: Multipool_View(),
    );
  }
}
