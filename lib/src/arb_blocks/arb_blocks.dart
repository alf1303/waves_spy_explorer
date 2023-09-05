import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waves_spy/src/arb_blocks/blocks_provider.dart';
import 'package:waves_spy/src/arb_blocks/widgets.dart';
import 'package:waves_spy/src/charts/puzzle/eagle_earnings.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:waves_spy/src/main_page.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/input_widget.dart';

class ArbBlocks extends StatelessWidget {
  const ArbBlocks({Key? key}) : super(key: key);
  static const routeName = "arb_blocks";

  Future<String> pasteFromClipboardBlock() async{
    final blocksProvider = BlocksProvider();
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
    String? copiedtext = cdata?.text;
    if (copiedtext != null) {
      // controller.text = copiedtext;
      blocksProvider.block = int.parse(copiedtext);
      blocksProvider.byBlock = true;
      blocksProvider.notifyAll();
      return copiedtext;
    }
    return "";
  }

  Future<String> pasteFromClipboardTx() async{
    final blocksProvider = BlocksProvider();
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
    String? copiedtext = cdata?.text;
    if (copiedtext != null) {
      // controller.text = copiedtext;
      blocksProvider.txid = copiedtext;
      blocksProvider.byBlock = false;
      blocksProvider.notifyAll();
      return copiedtext;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    final blockController = TextEditingController();
    final txController = TextEditingController();
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
      body: Column(
        children: [
          StatefulBuilder(
            builder: (context, setState) {
              return Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () async{
                              blockController.text = await pasteFromClipboardBlock();
                              setState(() {});
                            },
                            icon: Icon(Icons.paste, size: iconSize,)),
                        Expanded(
                          child: InputWidgetFilter(
                            label: "block: ",
                            controller: blockController,
                            fontSize: fontSize,
                            submit: true,
                            onchanged: onSubmitBlock,
                            isNumeric: true
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () async{
                                    txController.text = await pasteFromClipboardTx();
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.paste, size: iconSize,)),
                              Expanded(
                                child: InputWidgetFilter(
                                    label: "txid: ",
                                    controller: txController,
                                    fontSize: fontSize,
                                    submit: true,
                                    onchanged: onSubmitTx,
                                    isNumeric: true
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }
          ),
          Expanded(child: ViewBlockWidget())
        ],
      ),
    );
  }

  void onSubmitBlock(val) {
    final blocksProvider = BlocksProvider();
    blocksProvider.block = int.parse(val);
    blocksProvider.byBlock = true;
    blocksProvider.notifyAll();
  }

  void onSubmitTx(val) {
    final blocksProvider = BlocksProvider();
    blocksProvider.txid = val;
    blocksProvider.byBlock = false;
    blocksProvider.notifyAll();
  }
}
