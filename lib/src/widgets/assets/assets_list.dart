import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/models/asset.dart';
import 'package:waves_spy/src/providers/asset_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/assets/asset_view.dart';
import 'package:waves_spy/src/widgets/data/data_list.dart';
import 'package:waves_spy/src/widgets/other/progress_bar.dart';


class AssetsList extends StatelessWidget {
  AssetsList({Key? key}) : super(key: key);
  final _textController = TextEditingController();

  filterByName(val) {
    final _assetProvider = AssetProvider();
    _assetProvider.changeNameFilter(val);
  }

  clearAssetName() {
    final _assetProvider = AssetProvider();
    _textController.text = "";
    _assetProvider.clearNameFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const MyProgressBar(label: "assets"),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Row(
              children: [
                SizedBox(width: 250, child: Text("Name")),
                SizedBox(width: 150, child: Text("Wallet")),
                SizedBox(width: 150, child: Text("Staked")),
                SizedBox(width: 70, child: Text("Issue")),
                SizedBox(width: 70, child: Text("Scripted")),
                Expanded(
                  child: SizedBox(child: Consumer<AssetProvider>(
                    builder: (context, model, child) {
                      return Row(
                        children: [
                          Text("ID                     "),
                          Expanded(child: TextFormField(
                            controller: _textController,
                            onChanged: filterByName,
                            decoration: InputDecoration(isDense: false, hintText: "enter name or id to filter", hintStyle: TextStyle(color: Colors.cyan)),
                          ),
                          ),
                          IconButton(onPressed: clearAssetName, icon: const Icon(Icons.close, color: Colors.cyan,), tooltip: "clear",)
                        ],
                      );
                    },
                  )),
                )
              ],
            ),
          ),
          Expanded(
            child: Consumer<AssetProvider>(
              builder: (context, model, child) {
                return BaseListWidget(model: model);
              },
            ),
          ),
        ],
      ),
    );
  }
}