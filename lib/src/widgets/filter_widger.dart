import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/models/asset.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/main_area.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:waves_spy/src/widgets/other/custom_group_radio.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../styles.dart';

class FilterWidget extends StatelessWidget {
  FilterWidget({Key? key}) : super(key: key);
  final selectedColor = Colors.cyanAccent;
  final functController = TextEditingController();
  final assetController = TextEditingController();
  final minValueController = TextEditingController();
  final addressController = TextEditingController();
  String dirValue = "";

  final dirs = ["all", "in", "out"];

  @override
  Widget build(BuildContext context) {
    // return const Center(child: Text("FILTER BUTTONS"),);
    final apploc = AppLocalizations.of(context);
    final _filterProvider = FilterProvider();
    final _transactionProvider = TransactionProvider();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Consumer<FilterProvider>(
        builder: (context, model, child) {
          assetController.text = _filterProvider.assetName.name;
          functController.text = _filterProvider.functName;
          minValueController.text = _filterProvider.minValue.toString();
          addressController.text = _filterProvider.addrName;
          assetController.selection = TextSelection.fromPosition(TextPosition(offset: assetController.text.length));
          functController.selection = TextSelection.fromPosition(TextPosition(offset: functController.text.length));
          minValueController.selection = TextSelection.fromPosition(TextPosition(offset: minValueController.text.length));
          addressController.selection = TextSelection.fromPosition(TextPosition(offset: addressController.text.length));

          dirValue = _filterProvider.direction;
          bool funcNameVisible = _filterProvider.fType.contains(16);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        CustomGroupRadio(label: "Issue", value: 3, groupValue: model.fType, onChanged: onTypeChanged, enabled: true, color: selectedColor),
                        CustomGroupRadio(label: "Burn", value: 6, groupValue: model.fType, onChanged: onTypeChanged, enabled: true, color: selectedColor),
                        IconButton(onPressed: clearType, icon: const Icon(Icons.close,), tooltip: "clear type",)
                      ],
                    ),
                  ),
                  IconButton(onPressed: onReverseChange,
                    icon: Icon(model.reverseTransactions ? Icons.arrow_upward_outlined : Icons.arrow_downward_rounded),
                    tooltip: model.reverseTransactions ? apploc!.newFirst : apploc!.oldFirst,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                      child: Row(
                        children: [
                          Expanded(
                              child: InputWidgetFilter(controller: addressController, onchanged: addressChanged, clearFunc: clearAddress, label: "address", hint: apploc.clearAddress)
                          ),
                          Expanded(
                              child: InputWidgetFilter(controller: minValueController, onchanged: minValueChanged, clearFunc: minValueClear, label: "min value", hint: apploc.clearMinValue, isNumeric: true)
                          ),
                          Expanded(
                            child: Visibility(child: InputWidgetFilter(controller: functController, onchanged: functChanged, clearFunc: clearFunc, label: "function name", hint: apploc.clearFunction),
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
                    flex: 3,
                    child: Row(
                      children: [
                        loadButton(loadMore, "Load More"),
                        loadButton(loadAll, "Load All"),
                        Expanded(
                          child: dateTimePicker(_filterProvider.changeFromDate, DateTime(2022).toString(),  "from", "clear from date")
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15,),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: dateTimePicker(_filterProvider.changeToDate, DateTime.now().add(const Duration(hours: 1)).toString(), "to", "clear to date")
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8,),
                  Expanded(
                    flex: 4,
                      child: assetFilter(context)
                  ),
                  directionSelect(),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                child: Consumer<TransactionProvider>(
                  builder: (context, model, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        model.filterData
                      ],
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget assetFilter(BuildContext context) {
    final apploc = AppLocalizations.of(context);
    return DropdownSearch<Asset>(
      showClearButton: true,
      popupProps: const PopupProps.menu(showSearchBox: true),
      dropdownSearchDecoration: InputDecoration(border: const OutlineInputBorder(),
          isDense: true,
          labelText: "asset name or id",
          suffixIcon: IconButton(onPressed: clearFunc, icon: const Icon(Icons.close,), tooltip: apploc?.clearAsset,)),
      asyncItems: (String filter) => getData(filter),
      itemAsString: (Asset u) => "${u.name} - ${u.id}",
      onChanged: (Asset? data) => assetChanged(data),
    );
  }

  Widget directionSelect() {
    return Tooltip(
      message: "direction of transfers",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: DropdownButton(
            items: dirs.map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Text(items),
              );
            }).toList(),
            value: dirValue,
            isDense: true,
            onChanged: onChangedDirection),
      ),
    );
  }

  Widget loadButton(funct, String text) {
    return InkWell(
      onTap: funct,
      hoverColor: hoverColor,
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(border: Border.all(color: Colors.greenAccent), borderRadius: BorderRadius.circular(8)),
        child: Text(text),
      ),
    );
  }

  Widget dateTimePicker(funct, String initialValue, String label, String tooltip) {
    return DateTimePicker(
      type: DateTimePickerType.dateTime,
      firstDate: DateTime(2018),
      lastDate: DateTime(2023),
      // dateLabelText: "from",
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          isDense: true,
          labelText: label,
          suffixIcon: IconButton(onPressed: clearFromDate, icon: const Icon(Icons.close,), tooltip: tooltip,)
      ),
      initialValue: initialValue,
      onChanged: (val) async{
        // await _filterProvider.changeFromDate(DateTime.parse(val));
        await funct(DateTime.parse(val));
      },
    );
  }

  // Widget dfsd() {
  //   return DateTimePicker(
  //     type: DateTimePickerType.dateTime,
  //     firstDate: DateTime(2018),
  //     lastDate: DateTime(2023),
  //     // dateLabelText: "to",
  //     decoration: InputDecoration(
  //       isDense: true,
  //       border: const OutlineInputBorder(),
  //       labelText: "to",
  //       suffixIcon: IconButton(onPressed: clearFunc, icon: const Icon(Icons.close,), tooltip: "clear to date",),
  //     ),
  //     initialValue: DateTime.now().add(const Duration(hours: 1)).toString(),
  //     onChanged: (val) {
  //       _filterProvider.changeToDate(DateTime.parse(val));
  //     },
  //   );
  // }

  Future<List<Asset>> getData(String filter) async{
    return assetsGlobal.values.where((ass) => ass.name.toLowerCase().contains(filter.toLowerCase())).toList();
  }

  loadMore() async {
    await loadMoreTr();
  }

  loadAll() async{
    await loadAllTr();
  }

  void onChangedDirection(val) {
    print("new direction: $val");
    final _filterProvider = FilterProvider();
    _filterProvider.changeDirection(val);
  }

  void onReverseChange() {
    final _filterProvider = FilterProvider();
    _filterProvider.changeReverse();
  }

  void minValueChanged(String val) {
    final _filterProvider = FilterProvider();
    _filterProvider.changeMinValue(val.replaceFirst(",", "."));
  }

  void minValueClear() {
    final _filterProvider = FilterProvider();
    _filterProvider.clearMinValue();
  }

  void onTypeChanged(val) {
    print(val);
    final _filterProvider = FilterProvider();
    _filterProvider.changeType(val);
  }

  void clearType() {
    final _filterProvider = FilterProvider();
    _filterProvider.clearType();
  }

  void functChanged(val) {
    final _filterProvider = FilterProvider();
    _filterProvider.changeFunctionName(val);
  }

  void clearFunc() {
    final _filterProvider = FilterProvider();
    _filterProvider.clearFunc();
  }

  void addressChanged(val) {
    final _filterProvider = FilterProvider();
    _filterProvider.changeAddressName(val);
  }

  void clearAddress() {
    final _filterProvider = FilterProvider();
    _filterProvider.clearAddress();
  }

  void assetChanged(Asset? val) {
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

}

Widget InputWidgetFilter({controller, onchanged, clearFunc, label, hint, bool? isNumeric, bool? padded}) {
  bool isNum = isNumeric ?? false;
  final bool padde = padded ?? false;
  return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      // decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Row(
          children: [
      Expanded(
      child: Padding(
        padding: padde ? const EdgeInsets.only(left: 20.0, right: 150, bottom: 10) : const EdgeInsets.all(4),
        child: TextFormField(
        onChanged: onchanged,
            // onFieldSubmitted: onchanged,
            controller: controller,
            keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : null,
            inputFormatters: isNum ? [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
            ] : [],
        decoration: InputDecoration(
        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blueGrey)),
        isDense: true,
        labelText: label,
        suffixIcon: IconButton(onPressed: clearFunc, icon: const Icon(Icons.close,), tooltip: hint,)
  ),
  ),
      ),
  ),
  ],
  ),
  );
}