import 'package:flutter/material.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';

class InputWidget extends StatelessWidget {
  InputWidget({Key? key}) : super(key: key);

  final _inputController = TextEditingController();
  final _transactionProvider = TransactionProvider();

  onSearch() async{
    _transactionProvider.setCurrAddr(_inputController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(
          onPressed: onSearch,
          icon: const Icon(Icons.search_rounded)),
      Expanded(
        child: TextField(
          controller: _inputController,
        ),
      ),
    ],
    );
  }
}