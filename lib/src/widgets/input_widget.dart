import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';

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
    await _transactionProvider.setCurrAddr(_inputController.text);
  }

  loadMore() async {
    await _transactionProvider.getMoreTransactions();
  }

  loadAll() async {
    await _transactionProvider.getllTransactions();
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
      IconButton(
          onPressed: pasteFromClipboard,
          tooltip: apploc?.paste,
          icon: const Icon(Icons.paste)),
      Consumer<TransactionProvider>(
        builder: (context, model, child) {
          _inputController.text = _transactionProvider.curAddr.isEmpty ? "3PAtzncjJGWRpCtkR55wAzcfZ9fubMeA4JU" : _transactionProvider.curAddr;
          return SizedBox(
            width: 500,
            child: TextField(
              textInputAction: TextInputAction.go,
              controller: _inputController,
              decoration: InputDecoration(
                isDense: true,
                label: Text(apploc!.addrHint),
              ),
              onSubmitted: (val) {
                onSearch();
              },
            ),
          );
        },
      ),
      IconButton(
          onPressed: onSearch,
          tooltip: apploc!.search,
          icon: const Icon(Icons.search_rounded)),
      // TextButton(onPressed: loadMore, child: Text(apploc.loadMore)),
      // TextButton(onPressed: loadAll, child: Text(apploc.loadAll))


    ],
    );
  }
}