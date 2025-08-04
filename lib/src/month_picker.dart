import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';

/// A custom month picker widget that shows all 12 months in a grid layout
/// with keyboard navigation and styling support through [PickerDecoration].
class MyMonthPicker extends StatefulWidget {
  /// The initially selected date.
  final DateTime initialDate;

  /// The date currently being displayed.
  final DateTime currentDisplayDate;

  /// Callback to switch to the year picker.
  final Function() changeToYearPicker;

  /// Callback when a month is selected.
  final Function(DateTime value) onDateChanged;

  /// Custom decoration and styling for the picker.
  final PickerDecoration? pickerDecoration;

  /// The height of the entire picker widget.
  final double height;

  /// The width of the entire picker widget.
  final double width;

  const MyMonthPicker({
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
  /// List of focus nodes for each month tile.
  late List<FocusNode> monthFocusNodes;

  /// Focus node for the header (month-year display).
  FocusNode monthYearFocusNode = FocusNode();

  /// Index of the currently focused month (0-based).
  late int focusMonthIndex;

  /// List of DateTime objects representing each month of the current year.
  late List<DateTime> monthsList;

  @override
  void initState() {
    super.initState();

    // Generate list of months based on currentDisplayDate
    monthsList = List.generate(
      12,
      (i) => DateTime(widget.currentDisplayDate.year, i + 1, 1),
    );

    // Create focus nodes for each month tile
    monthFocusNodes = List.generate(12, (_) => FocusNode());

    // Set focus to currently selected month
    focusMonthIndex = widget.currentDisplayDate.month - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      monthFocusNodes[focusMonthIndex].requestFocus();
    });

    // Rebuild on header focus change
    monthYearFocusNode.addListener(() {
      if (mounted) setState(() {});
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

  /// Moves keyboard focus to the given [newIndex] of month.
  void moveFocus(int newIndex) {
    if (newIndex >= 0 && newIndex < 12) {
      setState(() {
        focusMonthIndex = newIndex;
        monthFocusNodes[focusMonthIndex].requestFocus();
      });
    } else {
      // Loop focus from end to start or start to end
      if (newIndex == 12) {
        setState(() {
          focusMonthIndex = 0;
          monthFocusNodes[focusMonthIndex].requestFocus();
        });
      }
      if (newIndex == -1) {
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
        /// Pressing Tab toggles between header and month grid.
        LogicalKeySet(LogicalKeyboardKey.tab): () {
          if (monthYearFocusNode.hasFocus) {
            focusMonthIndex = widget.currentDisplayDate.month - 1;
            FocusScope.of(
              context,
            ).requestFocus(monthFocusNodes[focusMonthIndex]);
          } else {
            focusMonthIndex = -1;
            monthYearFocusNode.requestFocus();
          }
        },

        /// Arrow navigation between months.
        LogicalKeySet(LogicalKeyboardKey.arrowRight): () =>
            moveFocus(focusMonthIndex + 1),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): () =>
            moveFocus(focusMonthIndex - 1),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): () =>
            moveFocus(focusMonthIndex - 3),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
          if (monthYearFocusNode.hasFocus) {
            focusMonthIndex = widget.currentDisplayDate.month - 1;
            FocusScope.of(
              context,
            ).requestFocus(monthFocusNodes[focusMonthIndex]);
          } else {
            moveFocus(focusMonthIndex + 3);
          }
        },

        /// Enter key selects month or opens year picker if on header.
        LogicalKeySet(LogicalKeyboardKey.enter): () {
          if (monthYearFocusNode.hasFocus) {
            widget.changeToYearPicker();
          } else {
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
              /// Header displaying the current year.
              Container(
                width: widget.width,
                alignment:
                    widget.pickerDecoration?.headerDecoration?.alignment ??
                        Alignment.center,
                margin:
                    widget.pickerDecoration?.headerDecoration?.headerMargin ??
                        EdgeInsets.zero,
                padding:
                    widget.pickerDecoration?.headerDecoration?.headerPadding ??
                        EdgeInsets.all(10),
                decoration: widget
                        .pickerDecoration?.headerDecoration?.headerDecoration ??
                    BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusNode: monthYearFocusNode,
                    focusColor: widget.pickerDecoration?.headerDecoration
                            ?.iconDecoration?.focusColor ??
                        Colors.white,
                    hoverColor: widget.pickerDecoration?.headerDecoration
                            ?.iconDecoration?.hoverColor ??
                        Colors.white12,
                    borderRadius: BorderRadius.circular(5),
                    onTap: () => widget.changeToYearPicker(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        "Jan - Dec ${widget.currentDisplayDate.year}",
                        style: headerStyle(),
                      ),
                    ),
                  ),
                ),
              ),

              /// Month grid
              Expanded(
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio:
                        (widget.width / 2.5) / (widget.height / 4),
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final isSelected =
                        index == widget.currentDisplayDate.month - 1;
                    final isFocused = index == focusMonthIndex;

                    return Focus(
                      focusNode: monthFocusNodes[index],
                      child: InkWell(
                        hoverColor: widget.pickerDecoration?.monthDecoration
                                ?.hoverColor ??
                            Colors.transparent,
                        focusColor: widget.pickerDecoration?.monthDecoration
                                ?.focusColor ??
                            Colors.transparent,
                        onTap: () {
                          widget.onDateChanged(monthsList[index]);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: monthDecoration(isSelected, isFocused),
                          alignment: Alignment.center,
                          child: Text(
                            DateFormat.MMM().format(monthsList[index]),
                            style: monthStyle(isSelected, isFocused),
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

  /// Returns the text style for each month tile.
  TextStyle monthStyle(bool isSelected, bool isFocused) {
    if (isFocused && !isSelected) {
      return widget.pickerDecoration?.monthDecoration?.disableTextStyle ??
          TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.normal,
          );
    } else if (isSelected) {
      return widget.pickerDecoration?.monthDecoration?.selectedTextStyle ??
          TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          );
    } else {
      return widget.pickerDecoration?.monthDecoration?.unSelectedTextStyle ??
          const TextStyle(color: Colors.black, fontWeight: FontWeight.normal);
    }
  }

  /// Returns the header text style, adapting to focus state.
  TextStyle headerStyle() {
    if (monthYearFocusNode.hasFocus) {
      return widget.pickerDecoration?.headerDecoration?.focusTextStyle ??
          const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          );
    } else {
      return widget.pickerDecoration?.headerDecoration?.headerTextStyle ??
          const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          );
    }
  }

  /// Returns the decoration for each month tile depending on selection/focus.
  BoxDecoration monthDecoration(bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.monthDecoration?.focusDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          );
    } else if (isSelected) {
      return widget.pickerDecoration?.monthDecoration?.selectedDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor),
          );
    } else {
      return widget.pickerDecoration?.monthDecoration?.unSelectedDecoration ??
          BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          );
    }
  }
}
