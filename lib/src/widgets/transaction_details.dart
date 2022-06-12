import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
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
    final fontSize = getFontSize(context);
    final textStyle = TextStyle(fontSize: fontSize);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(fontSize*3),
        child: AppBar(
          title: TabBar(
            controller: tabController2,
            tabs: [
              // Tab(text: "Raw", ),
              // Tab(text: "Pretty",)
              Tab(child: Text("Raw", style: textStyle,), ),
              Tab(child: Text("Pretty", style: textStyle,),)
            ],
          ),
        ),
      ),
      body: Consumer<TransactionDetailsProvider>(
        builder: (context, model, child) {
          return TabBarView(
            controller: tabController2,
            children: [
              SingleChildScrollView(
                  primary: false,
                  child: SelectableText(model.tr, style: textStyle,)),
              Center(child: Text("Not implemented yet", style: textStyle,))
            ],
          );
        },
      )
    );
  }
}
