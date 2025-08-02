import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';

class MyMonthPicker extends StatefulWidget {
  final DateTime? lastDate;
  final double height,width;
  final DateTime? firstDate;
  final DateTime initialDate;
  final DateTime currentDisplayDate;
  final Function() changeToYearPicker;
  final PickerDecoration? pickerDecoration;
  final Function(DateTime value) onDateChanged;

  const MyMonthPicker({
    this.lastDate,
    this.firstDate,
    required this.width,
    required this.height,
    this.pickerDecoration,
    required this.initialDate,
    required this.onDateChanged,
    required this.currentDisplayDate,
    required this.changeToYearPicker,
    super.key,
  });

  @override
  State<MyMonthPicker> createState() => _MyMonthPickerState();
}

class _MyMonthPickerState extends State<MyMonthPicker> {
  late List<FocusNode> monthFocusNodes;
  FocusNode monthYearFocusNode = FocusNode();
  late int focusMonthIndex;
  late List<DateTime> monthsList;

  @override
  void initState() {
    super.initState();
     monthsList = List.generate(12, (i) => DateTime(widget.currentDisplayDate.year, i + 1, 1));

    monthFocusNodes = List.generate(12, (_) => FocusNode());
    focusMonthIndex = widget.currentDisplayDate.month - 1;

    // Focus on the month when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      monthFocusNodes[focusMonthIndex].requestFocus();
    });

    monthYearFocusNode.addListener(() {
      if(mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    for (final node in monthFocusNodes) {
      node.dispose();
    }
    monthYearFocusNode.dispose();
    super.dispose();
  }

  void moveFocus(int newIndex) {
    if (newIndex >= 0 && newIndex < 12) {
      setState(() {
        focusMonthIndex = newIndex;
        monthFocusNodes[focusMonthIndex].requestFocus();
      });
    }else{
      if(newIndex == 12) {
        setState(() {
          focusMonthIndex = 0;
          monthFocusNodes[focusMonthIndex].requestFocus();
        });
      }
      if(newIndex == -1) {
        setState(() {
          focusMonthIndex = 11;
          monthFocusNodes[focusMonthIndex].requestFocus();
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.tab): () {
          if (monthYearFocusNode.hasFocus) {
            focusMonthIndex = widget.currentDisplayDate.month - 1;
            FocusScope.of(context).requestFocus(monthFocusNodes[focusMonthIndex]);
          } else {
            focusMonthIndex = -1;
            monthYearFocusNode.requestFocus();
          }
        },


        LogicalKeySet(LogicalKeyboardKey.arrowRight): () => moveFocus(focusMonthIndex + 1),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): () => moveFocus(focusMonthIndex - 1),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): () => moveFocus(focusMonthIndex - 3),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
          if(monthYearFocusNode.hasFocus){
            focusMonthIndex = widget.currentDisplayDate.month - 1;
            FocusScope.of(context).requestFocus(monthFocusNodes[focusMonthIndex]);
          }else {
            moveFocus(focusMonthIndex + 3);
          }
        },
        LogicalKeySet(LogicalKeyboardKey.enter): () {
          if(monthYearFocusNode.hasFocus){
            widget.changeToYearPicker();
          }else {
            widget.onDateChanged(monthsList[focusMonthIndex]);
          }
        },
      },
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        type: MaterialType.transparency,
        child: SizedBox(
          height: widget.height,
          width: widget.width,
          child: Column(
            children: [
              Container(
                width: widget.width,

                alignment: widget.pickerDecoration?.headerDecoration?.alignment??  Alignment.center,
                margin: widget.pickerDecoration?.headerDecoration?.headerMargin ?? EdgeInsets.zero,
                padding: widget.pickerDecoration?.headerDecoration?.headerPadding ?? EdgeInsets.all(10),
                decoration:  widget.pickerDecoration?.headerDecoration?.headerDecoration ??BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child:  Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusNode: monthYearFocusNode,
                    focusColor: widget.pickerDecoration?.headerDecoration?.iconDecoration?.focusColor ?? Colors.white,
                    hoverColor: widget.pickerDecoration?.headerDecoration?.iconDecoration?.hoverColor ?? Colors.white12,
                    borderRadius: BorderRadius.circular(05),
                    onTap: () => widget.changeToYearPicker(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                          "Jan - Dec ${widget.currentDisplayDate.year}",
                          style: headerStyle()
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: 10),

              Expanded(
                child: GridView.builder(
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: (widget.width / 2.5) / (widget.height / 4),
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final isSelected = index == widget.currentDisplayDate.month - 1;
                    final isFocused = index == focusMonthIndex;

                    return Focus(
                      focusNode: monthFocusNodes[index],
                      child: InkWell(
                        hoverColor: widget.pickerDecoration?.monthDecoration?.hoverColor ?? Colors.transparent,
                        focusColor:  widget.pickerDecoration?.monthDecoration?.focusColor ?? Colors.transparent,
                        onTap: () {
                          widget.onDateChanged(monthsList[index]);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: monthDecoration(isSelected,isFocused), /*BoxDecoration(
                            color: isSelected
                                ? Colors.blue
                                : isFocused
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: isFocused ? Colors.blue : Colors.grey,
                              width: isFocused ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),*/
                          alignment: Alignment.center,
                          child: Text(
                            DateFormat.MMM().format(monthsList[index]),
                            style: monthStyle(isSelected,isFocused),/* TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),*/
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle monthStyle(isMonthSelected,isEnable){

    if(isEnable && !isMonthSelected){
      return widget.pickerDecoration?.monthDecoration?.disableTextStyle ?? TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.normal,
      );
    }else{
      if(isMonthSelected){
        return widget.pickerDecoration?.monthDecoration?.selectedTextStyle ?? TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        );
      }else{
        return widget.pickerDecoration?.monthDecoration?.unSelectedTextStyle ?? TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        );
      }
    }
  }


  TextStyle headerStyle(){
    if(monthYearFocusNode.hasFocus){
      return widget.pickerDecoration?.headerDecoration?.focusTextStyle ?? TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    }
    else{
      return widget.pickerDecoration?.headerDecoration?.headerTextStyle ?? TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    }
  }

  BoxDecoration monthDecoration(isMonthSelected,isEnable){
    if(isEnable){
      return widget.pickerDecoration?.monthDecoration?.focusDecoration ?? BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).primaryColor,width: 2),
      );
    }else {
      if (isMonthSelected) {
        return widget.pickerDecoration?.monthDecoration?.selectedDecoration ?? BoxDecoration(
          // color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Theme.of(context).primaryColor
          ),
        );
      } else {
        return widget.pickerDecoration?.monthDecoration?.unSelectedDecoration ?? BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        );
      }
    }
  }
}