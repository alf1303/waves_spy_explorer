import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';

class InputWidget extends StatelessWidget {
  InputWidget({Key? key}) : super(key: key);

  final _inputController = TextEditingController();
  final _transactionProvider = TransactionProvider();

  onSearch() async{
    _transactionProvider.setCurrAddr(_inputController.text);
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
    _inputController.text = _transactionProvider.curAddr.isEmpty ? "3PGFHzVGT4NTigwCKP1NcwoXkodVZwvBuuU" : _transactionProvider.curAddr;
    return Row(children: [
      IconButton(
          onPressed: pasteFromClipboard,
          tooltip: apploc?.paste,
          icon: const Icon(Icons.paste)),
      SizedBox(
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
      ),
      IconButton(
          onPressed: onSearch,
          tooltip: apploc.search,
          icon: const Icon(Icons.search_rounded)),
      TextButton(onPressed: loadMore, child: Text(apploc.loadMore)),
      TextButton(onPressed: loadAll, child: Text(apploc.loadAll))


    ],
    );
  }
}