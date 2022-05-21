import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/data/data_list.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/nfts/nfts_list.dart';
import 'package:waves_spy/src/widgets/script/script_view.dart';
import 'package:waves_spy/src/widgets/stats/stats_view.dart';
import 'package:waves_spy/src/widgets/transactions/transactions_list.dart';

import 'assets/assets_list.dart';
import 'other/progress_bar.dart';

TabController? tabController;

class MainArea extends StatefulWidget {
  const MainArea({Key? key}) : super(key: key);

  @override
  State<MainArea> createState() => _MainAreaState();
}

class _MainAreaState extends State<MainArea>  with SingleTickerProviderStateMixin{

  @override
  void initState() {
    tabController = TabController(vsync: this, length: 6);
  }

  @override
  Widget build(BuildContext context) {
    final _transactionProvider = TransactionProvider();
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: tabController,
            tabs: const [
          Tab(text: "Transactions", icon: MyProgressBar(label: "trans")),
          Tab(text: "Assets", icon: MyProgressBar(label: "assets")),
          Tab(text: "NFTs", icon: MyProgressBar(label: "nfts")),
          Tab(text: "Data", icon: MyProgressBar(label: "data")),
          Tab(text: "Script", icon: MyProgressBar(label: "script")),
          Tab(text: "Stats",),

        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
                controller: tabController,
                children: [
              TransactionsList(),
              AssetsList(),
              NftList(),
              DataList(),
              ScriptView(),
              StatsView()
            ]),
          ),
        ],
      ),
    );
  }
}
