import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
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
    final radius = Radius.circular(16);
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
            // indicator: ShapeDecoration(
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: radius, topLeft: radius)),
            //     color: Colors.white10
            // ),
          controller: tabController,
            tabs: const [
          // const Tab(text: "Transactions", icon: const MyProgressBar(label: "trans"),),
          // Tab(text: "Assets", icon: MyProgressBar(label: "assets")),
          // Tab(text: "NFTs", icon: MyProgressBar(label: "nfts")),
          // // Tab(text: "Data", icon: MyProgressBar(label: "data")),
          // Tab(icon: MyProgressBar(label: "data"), child: Row(children: [Text("Data"), Icon(Icons.check_rounded, color: Colors.greenAccent,)],),),
          // Tab(text: "Script", icon: MyProgressBar(label: "script")),
          // Tab(text: "Stats",),
              TabHeaderWidget(name: "Transactions", label: "trans", index: 0),
              TabHeaderWidget(name: "Assets", label: "assets",index: 1,),
              TabHeaderWidget(name: "Nfts", label: "nfts", index: 2,),
              TabHeaderWidget(name: "Data", label: "data", index: 3,),
              TabHeaderWidget(name: "Script", label: "script", index: 4,),
              TabHeaderWidget(name: "Stats", label: "none", index: 5,),

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
  const TabHeaderWidget({Key? key, required String this.name, required String this.label, required int this.index}) : super(key: key);
  final name;
  final label;
  final index;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, model, child) {
        return Tab(
          // icon: MyProgressBar(label: label),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyProgressBar(label: label),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text(name),
                label == "none" ? Container() : model.isPresent(label) ?
                label == "script" ? const Icon(Icons.check_rounded, color: Colors.greenAccent) :
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(" (${model.getLoadedItemsCountProxy(label).toString()})", style: const TextStyle(color: Colors.greenAccent),),
                    Visibility(
                        visible: model.allTransactionsLoadedProxy(),
                        child: const Icon(Icons.check_rounded, color: Colors.greenAccent))
                  ],
                ) :
                const Icon(Icons.remove, color: Colors.redAccent,)
              ],
              ),
            ],
          ),
        );
      }
    );
  }
}

