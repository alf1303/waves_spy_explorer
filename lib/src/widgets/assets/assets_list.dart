import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/asset.dart';
import 'package:waves_spy/src/providers/asset_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/assets/asset_view.dart';
import 'package:waves_spy/src/widgets/data/data_list.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/input_widget.dart';
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
    final width = getWidth(context);
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    final textStyle = TextStyle(fontSize: fontSize);
    final isNarr = isNarrow(context);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          // const MyProgressBar(label: "assets"),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Row(
              children: [
                SizedBox(width: width*0.19, child: Text("Name", style: textStyle,),),
                SizedBox(width: width*0.11, child: Text("Wallet", style: textStyle)),
                // SizedBox(width: width*0.05, child: Container()), //Text("Staked")),
                !isNarr ? SizedBox(width: width*0.06, child: Text("Issue", style: textStyle)) : Container(),
                // !isNarr ? SizedBox(width: width*0.06, child: Text("Scripted", style: textStyle)) : Container(),
                Expanded(
                  child: SizedBox(child: Consumer<AssetProvider>(
                    builder: (context, model, child) {
                      return Row(
                        children: [
                          !isNarr ? Text("ID                     ", style: textStyle) : Container(),
                          Expanded(
                            child: SizedBox(
                                height: fontSize*4,
                                child: InputWidgetFilter(controller: _textController, onchanged: filterByName, hint: "clear", clearFunc: clearAssetName, label: "enter name or id to filter", fontSize: fontSize, iconSize: iconSize)),
                          ),
                        ],
                      );
                    },
                  )),
                )
              ],
            ),
          ),
          !isNarr ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 3.0),
            child: Divider(height: 4, color: Colors.blueGrey,),
          ) : Container(),
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
