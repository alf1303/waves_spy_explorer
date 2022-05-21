import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/progress_bars_provider.dart';
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
            tabs: [
          // const Tab(text: "Transactions", icon: const MyProgressBar(label: "trans"),),
          // Tab(text: "Assets", icon: MyProgressBar(label: "assets")),
          // Tab(text: "NFTs", icon: MyProgressBar(label: "nfts")),
          // // Tab(text: "Data", icon: MyProgressBar(label: "data")),
          // Tab(icon: MyProgressBar(label: "data"), child: Row(children: [Text("Data"), Icon(Icons.check_rounded, color: Colors.greenAccent,)],),),
          // Tab(text: "Script", icon: MyProgressBar(label: "script")),
          // Tab(text: "Stats",),
              TabHeaderWidget(name: "Transactions", label: "trans"),
              TabHeaderWidget(name: "Assets", label: "assets"),
              TabHeaderWidget(name: "Nfts", label: "nfts"),
              TabHeaderWidget(name: "Data", label: "data"),
              TabHeaderWidget(name: "Script", label: "script"),
              TabHeaderWidget(name: "Stats", label: "none"),

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

class TabHeaderWidget extends StatelessWidget {
  const TabHeaderWidget({Key? key, required String this.name, required String this.label}) : super(key: key);
  final name;
  final label;

  @override
  Widget build(BuildContext context) {
    final filterProvider = FilterProvider();
    return Consumer<ProgressProvider>(
      builder: (context, model, child) {
        return Tab(
          icon: MyProgressBar(label: label),
          child: Row( children: [
            Text(name),
            label == "none" ? Container() : model.isPresent(label) ? const Icon(Icons.check_rounded, color: Colors.greenAccent) : const Icon(Icons.remove, color: Colors.redAccent,)
          ],
          ),
        );
      }
    );
  }
}

