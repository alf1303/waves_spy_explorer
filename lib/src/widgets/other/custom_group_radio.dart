import 'package:flutter/material.dart';
import 'package:waves_spy/src/styles.dart';

class CustomGroupRadio extends StatefulWidget {
  final String label;
  final value;
  final groupValue;
  final ValueChanged<dynamic>? onChanged;
  final Color? color;
  final Color? selectedCol;
  final bool enabled;
  final double? margin;
  final double? padding;
  final double? fontSize;
  bool hover = false;
  @override
  State createState() {
    return CustomGroupRadioState();
  }
  CustomGroupRadio({
    required this.label,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
    required this.enabled,
    @required this.color,
    this.selectedCol,
    this.margin,
    this.padding,
    this.fontSize
  });
}

class CustomGroupRadioState extends State<CustomGroupRadio> {
  void onTapFunction() {
    setState(() {
      // bool res = widget.value == widget.groupValue;
      bool res = widget.groupValue.contains(widget.value);
      widget.onChanged!(widget.value);
    });
  }

  void onHoverFunction(val) {
    setState(() {
      // print(val);
      widget.hover = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    //print("groupradiobut ${widget.selectedCol}");
    // print("${widget.fontSize}");
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: widget.margin == null ? 5 : widget.margin!),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: widget.padding == null ? 5 : widget.padding!),
      decoration: BoxDecoration(
          border: Border.all(color: (widget.enabled && widget.groupValue.contains(widget.value)) ? widget.color! : Colors.transparent),
          color: !widget.hover ?
                    widget.selectedCol == null ? Colors.black12 : (widget.enabled && widget.groupValue.contains(widget.value)) ? widget.selectedCol : Colors.grey:
                    Colors.blueGrey,
          borderRadius: BorderRadius.circular(7)
      ),
      child: InkWell(
        onHover: onHoverFunction,
          onTap: widget.enabled ? onTapFunction : null,
          child: FittedBox(fit: BoxFit.fitWidth, child: Text(widget.label, style: TextStyle(fontSize: widget.fontSize == null ? 14 : widget.fontSize, color: Colors.white),))),
    );
  }
}