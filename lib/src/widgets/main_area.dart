import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/transactions/transactions_list.dart';

import 'assets/assets_list.dart';

TabController? tabController;

class MainArea extends StatefulWidget {
  const MainArea({Key? key}) : super(key: key);

  @override
  State<MainArea> createState() => _MainAreaState();
}

class _MainAreaState extends State<MainArea>  with SingleTickerProviderStateMixin{

  @override
  void initState() {
    tabController = TabController(vsync: this, length: 5);
  }

  @override
  Widget build(BuildContext context) {
    final _transactionProvider = TransactionProvider();
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: tabController,
            tabs: const [
          Tab(text: "Transactions",),
          Tab(text: "Assets",),
          Tab(text: "NFTs",),
          Tab(text: "Data",),
          Tab(text: "Script",),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
                controller: tabController,
                children: [
              TransactionsList(),
              const AssetsList(),
              Center(child: Text("NFTs")),
              Center(child: Text("Data")),
              Center(child: Text("Script")),
            ]),
          ),
        ],
      ),
    );
  }
}
