import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/providers/transaction_details_provider.dart';
import 'package:waves_spy/src/widgets/main_area.dart';

TabController? tabController2;

class TransactionDetails extends StatefulWidget {
  const TransactionDetails({Key? key}) : super(key: key);

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    tabController2 = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: tabController2,
          tabs: const [
            Tab(text: "Raw",),
            Tab(text: "Pretty",)
          ],
        ),
      ),
      body: Consumer<TransactionDetailsProvider>(
        builder: (context, model, child) {
          return TabBarView(
            controller: tabController2,
            children: [
              SingleChildScrollView(
                  primary: false,
                  child: SelectableText(model.tr)),
              Text("Pretty")
            ],
          );
        },
      )
    );
  }
}
