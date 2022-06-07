import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
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


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      if (widget.address != null) {
        _transactionProvider.setCurrAddr(widget.address);
      }
    });

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
    await _transactionProvider.setCurrAddr(_inputController.text.trim());
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
    return Row(children: [
      MyToolTip(
        message: apploc?.paste,
        child: IconButton(
            onPressed: pasteFromClipboard,
            icon: const Icon(Icons.paste)),
      ),
      Consumer<TransactionProvider>(
        builder: (context, model, child) {
          _inputController.text = _transactionProvider.curAddr.isEmpty ? "3PAtzncjJGWRpCtkR55wAzcfZ9fubMeA4JU" : _transactionProvider.curAddr;
          return SizedBox(
            width: 500,
            child: TextFormField(
              textInputAction: TextInputAction.go,
              controller: _inputController,
              decoration: InputDecoration(
                isDense: true,
                label: Text(apploc!.addrHint),
              ),
              onFieldSubmitted: (val) {
                onSearch();
              },
            ),
          );
        },
      ),
      MyToolTip(
        message: apploc!.search,
        child: IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search_rounded)),
      ),
      // TextButton(onPressed: loadMore, child: Text(apploc.loadMore)),
      // TextButton(onPressed: loadAll, child: Text(apploc.loadAll))


    ],
    );
  }
}