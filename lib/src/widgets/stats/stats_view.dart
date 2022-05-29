import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/constants.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/stats/addresses_stats_view.dart';
import 'package:waves_spy/src/widgets/stats/invokes_stats_view.dart';
import 'package:waves_spy/src/widgets/transactions/transaction_view.dart';

TabController? statsController;

class StatsView extends StatefulWidget {
  const StatsView({Key? key}) : super(key: key);

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    statsController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final _trProvider = TransactionProvider();
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
              controller: statsController,
              tabs: [
            Tab(child: Row(children: [
              const Text("Addresses"),
              Consumer<FilterProvider>(
                builder: (context, model, child) {
                  return model.assetName.id.isEmpty ? const Text("   (Select asset in filter to show addresses info)", style: TextStyle(color: Colors.yellowAccent),) : Container();
                },
              )
            ],)),
            const Tab(text: "Stats"),
          ]),
          Expanded(
            child: TabBarView(
                controller: statsController,
                children: const [
                  AddressesStatsView(),
                  InvokesStatsView()
            ]),
          )
        ]
      )
      );
  }
}
