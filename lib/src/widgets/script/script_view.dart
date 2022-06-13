import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/data_script_provider.dart';

class ScriptView extends StatefulWidget {
  const ScriptView({Key? key}) : super(key: key);
  @override
  State<ScriptView> createState() => _ScriptViewState();
}

class _ScriptViewState extends State<ScriptView> with AutomaticKeepAliveClientMixin{

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    super.build(context);
    return Consumer<DataScriptProvider>(builder: (context, model, child) {
      return Container( child:
      SingleChildScrollView(
        primary: false,
          child: SelectableText(model.script, style: TextStyle(fontSize: fontSize),)),
      padding: EdgeInsets.all(10),);
    });
  }

  @override
  bool get wantKeepAlive => true;

  // @override
  // void updateKeepAlive() {
  //   print("Oooooo");
  // }
}
