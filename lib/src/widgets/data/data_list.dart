import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/data_script_provider.dart';
import 'package:waves_spy/src/widgets/data/data_view.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/other/progress_bar.dart';

class DataList extends StatelessWidget {
  DataList({Key? key}) : super(key: key);
  final _textController = TextEditingController();

  filterByText(val) {
    final _dataProvider = DataScriptProvider();
    _dataProvider.changeNameFilter(val);
  }

  clearText() {
    final _dataProvider = DataScriptProvider();
    _textController.text = "";
    _dataProvider.clearNameFilter();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(context);
    final iconSize = getIconSize(context);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          // const MyProgressBar(label: "data"),
          Padding(padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: [
                Expanded(
                    child: SizedBox(
                      height: fontSize*4,
                      child: InputWidgetFilter(controller: _textController, onchanged: filterByText, hint: "clear", clearFunc: clearText,
                          label: "enter text to filter, use &&& or ||| for combining text expressions(if needed)", padded: true, fontSize: fontSize, iconSize: iconSize),
                    )
                ),
              ],
            )
          ),
          Expanded(child:
            Consumer<DataScriptProvider>(
              builder: ((context, model, child) {
                return BaseListWidget(model: model,);
              }),
            ),)
        ],
      ),
    );
  }
}

class BaseListWidget extends StatefulWidget {
  const BaseListWidget({Key? key, required this.model}) : super(key: key);
  final dynamic model;

  @override
  _BaseListWidgetState createState() => _BaseListWidgetState();
}

class _BaseListWidgetState extends State<BaseListWidget> with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ll = widget.model.filteredList;
    return ListView.builder(
        primary: false,
        itemCount: ll.length,
        itemBuilder: (context, i) {
          return widget.model.getItem(ll[i]);
        });
  }

  @override
  bool get wantKeepAlive => true;
}

