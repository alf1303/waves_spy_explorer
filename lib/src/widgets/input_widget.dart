import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:waves_spy/src/providers/progress_bars_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/other/custom_widgets.dart';

class InputWidget extends StatefulWidget {
  InputWidget({Key? key, this.address}) : super(key: key);
  final address;

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  final _inputController = TextEditingController();

  final _transactionProvider = TransactionProvider();
  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      if (widget.address != null) {
        _transactionProvider.setCurrAddr(widget.address);
      }
    });
    focusNode = FocusNode(canRequestFocus: false);
  }


  @override
  void dispose() {
    focusNode?.dispose();
  }

  onSearch() async{
    https://drive.google.com/uc?id=1CeaTZm40SEk_jpFooVLRLmYTrqAwV715&export=download
    // var resp = await http.get(Uri.parse("https://gist.githubusercontent.com/alf1303/79ee7fe6a760dad82c9049a351d1cbab/raw/da3f52844c7003f22a4f340926f2197ec4108d9d/gistfile1.txt"));
    // Map<String, String> requestHeaders = {
    //   'Content-type': 'application/json',
    //   'Accept': 'application/json'
    // };
    // var resp = await http.get(Uri.parse("https://gist.githubusercontent.com/alf1303/79ee7fe6a760dad82c9049a351d1cbab/raw/"));
    // String res = resp.body;
    // List<String> eles = res.split(",\n");
    // for(String el in eles) {
    //   if(!el.startsWith(" ")) {
    //     showSnackError(el);
    //     break;
    //   }
    // }
    // focusNode?.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_transactionProvider.isLoading) {
      _transactionProvider.isLoading = true;
      await _transactionProvider.setCurrAddr(_inputController.text.trim());
    }

  }

  loadMore() async {
    await _transactionProvider.getMoreTransactions();
  }

  loadAll() async {
    await _transactionProvider.getAllTransactions();
  }

  pasteFromClipboard() async{
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
    String? copiedtext = cdata?.text;
    if (copiedtext != null) {
      _inputController.text = copiedtext;
      await onSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final apploc = AppLocalizations.of(context);
    final height = getHeight(context);
    final width = getWidth(context);
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    final isNarr = isNarrow(context);
    return Row(children: [
      MyToolTip(
        message: apploc?.paste,
        child: Visibility(
          visible: !isNarr,
          child: IconButton(
              onPressed: pasteFromClipboard,
              icon: Icon(Icons.paste, size: iconSize,)),
        ),
      ),
      Consumer<TransactionProvider>(
        builder: (context, model, child) {
          _inputController.text = _transactionProvider.curAddr.isEmpty ? "3PGFHzVGT4NTigwCKP1NcwoXkodVZwvBuuU" : _transactionProvider.curAddr;
          return SizedBox(
            width: width*0.2,
            child: TextFormField(
              // textInputAction: TextInputAction.go,
              // focusNode: focusNode,
              controller: _inputController,
              style: TextStyle(fontSize: fontSize),
              decoration: InputDecoration(
                isDense: true,
                label: Text(apploc!.addrHint, style: TextStyle(fontSize: fontSize),),
              ),
              onFieldSubmitted: (val) {
                  onSearch();
                  // focusNode!.unfocus();
              },
            ),
          );
        },
      ),
      MyToolTip(
        message: apploc!.search,
        child: IconButton(
            onPressed: onSearch,
            icon: Icon(Icons.search_rounded, size: iconSize,)),
      ),
      // TextButton(onPressed: loadMore, child: Text(apploc.loadMore)),
      // TextButton(onPressed: loadAll, child: Text(apploc.loadAll))


    ],
    );
  }
}