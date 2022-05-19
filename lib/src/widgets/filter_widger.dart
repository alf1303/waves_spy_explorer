import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/main_area.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:waves_spy/src/widgets/other/custom_group_radio.dart';

class FilterWidget extends StatelessWidget {
  FilterWidget({Key? key}) : super(key: key);
  final selectedColor = Colors.cyanAccent;
  final functController = TextEditingController();
  final assetController = TextEditingController();
  String dirValue = "";

  final dirs = ["all", "in", "out"];

  void onChangedDirection(val) {
    print("new direction: $val");
    final _filterProvider = FilterProvider();
    _filterProvider.changeDirection(val);
  }

  void onTypeChanged(val) {
    final _filterProvider = FilterProvider();
    _filterProvider.changeType(val);
  }

  void clearType() {
    final _filterProvider = FilterProvider();
    _filterProvider.clearType();
  }

  void functChanged(val) {
    print("func: " + val);
    final _filterProvider = FilterProvider();
    _filterProvider.changeFunctionName(val);
  }

  void clearFunc() {
    final _filterProvider = FilterProvider();
    _filterProvider.clearFunc();
  }

void assetChanged(val) {
    print("asset: " + val);
  final _filterProvider = FilterProvider();
  _filterProvider.changeAssetName(val);
}

void clearAsset() {
  final _filterProvider = FilterProvider();
  _filterProvider.clearAsset();
}

void clearToDate() {
  final _filterProvider = FilterProvider();
  _filterProvider.clearToDate();
}

  void clearFromDate() {
    final _filterProvider = FilterProvider();
    _filterProvider.clearFromDate();
  }

  @override
  Widget build(BuildContext context) {
    // return const Center(child: Text("FILTER BUTTONS"),);
    final apploc = AppLocalizations.of(context);
    final _filterProvider = FilterProvider();
    final _transactionProvider = TransactionProvider();
    return Consumer<FilterProvider>(
      builder: (context, model, child) {
        assetController.text = _filterProvider.assetName;
        functController.text = _filterProvider.functName;
        assetController.selection = TextSelection.fromPosition(TextPosition(offset: assetController.text.length));
        functController.selection = TextSelection.fromPosition(TextPosition(offset: functController.text.length));
        dirValue = _filterProvider.direction;
        bool funcNameVisible = _filterProvider.fType == 16;
        return Column(
          children: [
            Row(
              children: [
                Container(
                  height: 57,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  // decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Row(
                    children: [
                      CustomGroupRadio(label: "Asset transfer", value: 4, groupValue: model.fType, onChanged: onTypeChanged, enabled: true, color: selectedColor,),
                      CustomGroupRadio(label: "Mass Payment", value: 11, groupValue: model.fType, onChanged: onTypeChanged, enabled: true, color: selectedColor),
                      CustomGroupRadio(label: "Invoke", value: 16, groupValue: model.fType, onChanged: onTypeChanged, enabled: true, color: selectedColor),
                      CustomGroupRadio(label: "Exchange", value: 7, groupValue: model.fType, onChanged: onTypeChanged, enabled: true, color: selectedColor),
                      IconButton(onPressed: clearType, icon: const Icon(Icons.close,), tooltip: "clear type",)
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    // decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Row(
                      children: [
                        Expanded(
                          child: InputWidget(controller: assetController, onchanged: assetChanged, clearFunc: clearAsset, label: "asset name", hint: apploc?.clearAsset),
                        ),
                        DropdownButton(
                            items: dirs.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                            value: dirValue,
                            isDense: true,
                            onChanged: onChangedDirection),
                        Expanded(
                          child: Visibility(child: InputWidget(controller: functController, onchanged: functChanged, clearFunc: clearFunc, label: "function name", hint: apploc?.clearFunction),
                            visible: funcNameVisible,)
                ),
              ],
            )
            )
            )
            ]),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: DateTimePicker(
                          type: DateTimePickerType.dateTime,
                          firstDate: DateTime(2018),
                          lastDate: DateTime(2023),
                          dateLabelText: "from",
                          initialValue: DateTime(2022).toString(),
                          onChanged: (val) async{
                            await _filterProvider.changeFromDate(DateTime.parse(val));
                          },
                        ),
                      ),
                      IconButton(onPressed: clearFromDate, icon: const Icon(Icons.close,), tooltip: "clear from date",)
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: DateTimePicker(
                          type: DateTimePickerType.dateTime,
                          firstDate: DateTime(2018),
                          lastDate: DateTime(2023),
                          dateLabelText: "to",
                          initialValue: DateTime.now().add(Duration(hours: 1)).toString(),
                          onChanged: (val) {
                            _filterProvider.changeToDate(DateTime.parse(val));
                          },
                        ),
                      ),
                      IconButton(onPressed: clearFunc, icon: const Icon(Icons.close,), tooltip: "clear to date",)
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Consumer<TransactionProvider>(
                      builder: (context, model, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(model.header),
                            Text(model.filterData)
                          ],
                        );
                      },
                    ),
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }

  Widget InputWidget({controller, onchanged, clearFunc, label, hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      // decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              onChanged: onchanged,
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                labelText: label,
              ),
            ),
          ),
          IconButton(onPressed: clearFunc, icon: const Icon(Icons.close,), tooltip: hint,)
        ],
      ),
    );
  }
}