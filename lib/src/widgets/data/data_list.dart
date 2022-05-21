import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/providers/data_script_provider.dart';
import 'package:waves_spy/src/widgets/data/data_view.dart';
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // const MyProgressBar(label: "data"),
          Padding(padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: [
                Expanded(child: TextFormField(
                  onChanged: filterByText,
                  controller: _textController,
                  decoration: const InputDecoration(isDense: false, hintText: "enter text to filter", hintStyle: TextStyle(color: Colors.cyan)),
                ),
                ),
                IconButton(onPressed: clearText, icon: const Icon(Icons.close, color: Colors.cyan,), tooltip: "clear",)
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

