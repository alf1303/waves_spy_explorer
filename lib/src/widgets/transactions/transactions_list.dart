import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/widgets/filter_bar.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/other/progress_bar.dart';
import 'package:waves_spy/src/widgets/transactions/base_transaction_view.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

import '../../providers/transaction_provider.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({Key? key, this.transactionsList}) : super(key: key);
  final List<dynamic>? transactionsList;

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  late ScrollController controller;
  bool _loadingM = false;

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  Future<void> _scrollListener() async {
    final _transactionProvider = TransactionProvider();
    // print(controller.position.extentAfter);
    if (controller.position.extentAfter == 0 && !_loadingM) {
      _loadingM = true;
      await _transactionProvider.getMoreTransactions();
      _loadingM = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _transactionProvider = TransactionProvider();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // const MyProgressBar(label: "trans"),
          FilterBar(),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, model, child) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: model.filteredTransactions.length,
                    controller: controller,
                    itemBuilder: (context, i) {
                      return BaseTransactionView(td: model.filteredTransactions[i]);
                      // return Card(child: ListTile(
                      //   title: Text("${model.filteredTransactions[i]["id"]}"),
                      // ),);
                    }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
