import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:waves_spy/src/widgets/filter_widger.dart';
import 'package:waves_spy/src/widgets/other/custom_widgets.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconSize = getIconSize(context);
    final isNarr = isNarrow(context);
    return isNarr ? Row(
      children: [
        IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return MyDialog(child: FilterWidget(), iconSize: iconSize);
                  });
            },
            icon: Icon(Icons.filter_alt_outlined)),
        Expanded(child: FilterData())
      ],
    ) :
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilterWidget(),
        FilterData()
      ],
    );
  }
}

Widget FilterData() {
  return Container(
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
  );
}
