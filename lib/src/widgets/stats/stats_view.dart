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

import '../../styles.dart';
import 'ducks_stats_view.dart';

TabController? statsController;

class StatsView extends StatefulWidget {
  const StatsView({Key? key}) : super(key: key);

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    statsController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final _trProvider = TransactionProvider();
    var radius = Radius.circular(10);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            // indicator: ShapeDecoration(
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: radius, topLeft: radius)),
            //     color: Colors.white10
            // ),
              controller: statsController,
              tabs: const[
            Tab(child: Text("Addresses stats")),
            Tab(child: Text("Ducks stats"),),
            Tab(child: Text("Call Stats"),),
          ]),
          Expanded(
            child: TabBarView(
                controller: statsController,
                children: const [
                  AddressesStatsView(),
                  DucksStatsView(),
                  InvokesStatsView()
            ]),
          )
        ]
      )
      );
  }
}
