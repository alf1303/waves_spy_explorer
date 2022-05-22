import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/providers/nft_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/data/data_list.dart';
import 'package:waves_spy/src/widgets/nfts/nft_view.dart';
import 'package:waves_spy/src/widgets/other/progress_bar.dart';

class NftList extends StatefulWidget {
  const NftList({Key? key, this.nftsList}) : super(key: key);
  final List<dynamic>? nftsList;

  @override
  State<NftList> createState() => _NftListState();
}

class _NftListState extends State<NftList> {
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

Future<void> _scrollListener() async{
    final _transactionProvider = TransactionProvider();
    if(controller.position.extentAfter == 0 && !_loadingM) {
      _loadingM = true;
      await _transactionProvider.getMoreNfts();
      _loadingM = false;
    }
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // const MyProgressBar(label: "nfts"),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Row(
              children: const [
                SizedBox(width: 300, child: Text("Name"),),
                SizedBox(width: 450, child: Text("Id"),),
                SizedBox(child: Text("Issuer"),),
              ],
            ),
          ),
          Expanded(
              child: Consumer<NftProvider>(
                builder: (context, model, child) {
                  return BaseListWidget(model: model);
                },
              ))
        ],
      ),
    );
  }

}

