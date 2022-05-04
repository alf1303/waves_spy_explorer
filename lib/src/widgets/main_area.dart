import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/transactions/transactions_list.dart';

class MainArea extends StatefulWidget {
  const MainArea({Key? key}) : super(key: key);

  @override
  State<MainArea> createState() => _MainAreaState();
}

class _MainAreaState extends State<MainArea>  with SingleTickerProviderStateMixin{
  TabController? _tabController;


  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 5);
  }

  @override
  Widget build(BuildContext context) {
    final _transactionProvider = TransactionProvider();
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _tabController,
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
          FilterWidget(),
          Expanded(
            child: TabBarView(
                controller: _tabController,
                children: [
              TransactionsList(),
              Center(child: Text("Assets")),
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
