import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

import '../../providers/transaction_provider.dart';

class TransactionsList extends StatelessWidget {
  TransactionsList({Key? key, this.transactionsList}) : super(key: key);

  List<dynamic>? transactionsList;

  @override
  Widget build(BuildContext context) {
    final _transactionProvider = TransactionProvider();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<TransactionProvider>(
        builder: (context, model, child) {
          return ListView.builder(
            itemCount: model.allTransactions.length,
              itemBuilder: (context, i) {
                return TransView(td: model.allTransactions[i]);
              }
          );
        },
      ),
    );
  }
}
