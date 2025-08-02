import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';

/// A customizable year picker widget with keyboard navigation and styling support.
/// Used for selecting a year within a range from [firstDate] to [lastDate].
class MyYearPicker extends StatefulWidget {
  /// The last selectable date.
  final DateTime? lastDate;

  /// The first selectable date.
  final DateTime? firstDate;

  /// The width of the picker.
  final double width;

  /// The height of the picker.
  final double height;

  /// The initially selected date.
  final DateTime initialDate;

  /// The currently displayed date (used to set initial focus).
  final DateTime currentDisplayDate;

  /// Callback when a year is selected.
  final Function(DateTime time) onDateChanged;

  /// Custom decoration and styling.
  final PickerDecoration? pickerDecoration;

  const MyYearPicker({
    this.lastDate,
    this.firstDate,
    required this.width,
    required this.height,
    this.pickerDecoration,
    required this.initialDate,
    required this.onDateChanged,
    required this.currentDisplayDate,
  });

  @override
  MyYearPickerState createState() => MyYearPickerState();
}

class MyYearPickerState extends State<MyYearPicker> {
  /// Focus nodes for each year in the grid.
  late List<FocusNode> monthFocusNodes;

  /// Index of the currently focused year.
  late int focusMonthIndex;

  /// Currently selected year.
  late int selectedYear;

  /// Currently selected month.
  late int selectedMonth;

  /// List of all years between [firstDate] and [lastDate].
  List<int> yearList = [];

  @override
  void initState() {
    super.initState();

    yearList = List.generate(
      (widget.lastDate?.year ?? 2100) - (widget.firstDate?.year ?? 1900) + 1,
      (i) => (widget.firstDate?.year ?? 1900) + i,
    );

    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;

    int startYear = widget.firstDate?.year ?? 1900;
    int endYear = widget.lastDate?.year ?? 2100;
    int totalYears = endYear - startYear + 1;

    monthFocusNodes = List.generate(totalYears, (_) => FocusNode());

    focusMonthIndex = widget.currentDisplayDate.year - startYear;

    // Focus on the currently displayed year
    WidgetsBinding.instance.addPostFrameCallback((_) {
      monthFocusNodes[focusMonthIndex].requestFocus();
    });
  }

  /// Recalculates year list and focus nodes when widget updates.
  @override
  void didUpdateWidget(covariant MyYearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.firstDate != oldWidget.firstDate ||
        widget.lastDate != oldWidget.lastDate) {
      yearList = List.generate(
        (widget.lastDate?.year ?? 2100) - (widget.firstDate?.year ?? 1900) + 1,
        (i) => (widget.firstDate?.year ?? 1900) + i,
      );

      selectedYear = widget.initialDate.year;
      selectedMonth = widget.initialDate.month;

      int startYear = widget.firstDate?.year ?? 1900;
      int endYear = widget.lastDate?.year ?? 2100;
      int totalYears = endYear - startYear + 1;

      monthFocusNodes = List.generate(totalYears, (_) => FocusNode());

      focusMonthIndex = widget.currentDisplayDate.year - startYear;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        monthFocusNodes[focusMonthIndex].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final node in monthFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Handles keyboard-based focus movement.
  void moveFocus(int newIndex) {
    final totalYears = monthFocusNodes.length;

    if (newIndex >= 0 && newIndex < totalYears) {
      setState(() {
        focusMonthIndex = newIndex;
        monthFocusNodes[focusMonthIndex].requestFocus();
      });
    } else {
      // Loop focus if it overflows
      if (newIndex == totalYears) {
        setState(() {
          focusMonthIndex = 0;
          monthFocusNodes[focusMonthIndex].requestFocus();
        });
      }
      if (newIndex == -1) {
        setState(() {
          focusMonthIndex = totalYears - 1;
          monthFocusNodes[focusMonthIndex].requestFocus();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        /// Tab key toggles focus on the grid.
        LogicalKeySet(LogicalKeyboardKey.tab): () {
          final currentYear = widget.currentDisplayDate.year;
          final startYear = widget.firstDate?.year ?? 1900;
          final index = currentYear - startYear;

          final fallbackIndex = (index >= 0 && index < monthFocusNodes.length)
              ? index
              : 0;

          if (!monthFocusNodes.any((node) => node.hasFocus)) {
            focusMonthIndex = fallbackIndex;
            final node = monthFocusNodes[focusMonthIndex];

            if (node.canRequestFocus) {
              node.requestFocus();
              final context = node.context;
              if (context != null) {
                Scrollable.ensureVisible(
                  context,
                  duration: const Duration(milliseconds: 300),
                  alignment: 0.5,
                );
              }
            }
          }
        },

        /// Arrow key navigation
        LogicalKeySet(LogicalKeyboardKey.arrowRight): () =>
            moveFocus(focusMonthIndex + 1),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): () =>
            moveFocus(focusMonthIndex - 1),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): () =>
            moveFocus(focusMonthIndex - 3),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): () =>
            moveFocus(focusMonthIndex + 3),

        /// Enter key selects the currently focused year
        LogicalKeySet(LogicalKeyboardKey.enter): () {
          if (focusMonthIndex >= 0 && focusMonthIndex < yearList.length) {
            final selectedYear = yearList[focusMonthIndex];
            final selectedMonth = widget.currentDisplayDate.month;
            final selectedDay = widget.currentDisplayDate.day;

            final maxDay = DateUtils.getDaysInMonth(
              selectedYear,
              selectedMonth,
            );
            final clampedDay = selectedDay > maxDay ? maxDay : selectedDay;

            final selectedDate = DateTime(
              selectedYear,
              selectedMonth,
              clampedDay,
            );
            widget.onDateChanged(selectedDate);
          }
        },
      },
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Column(
          children: [
            /// Header showing year range.
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
              decoration:
                  widget.pickerDecoration?.headerDecoration?.headerDecoration ??
                  BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
              child: Text(
                "${(widget.firstDate?.year ?? 1900)} - ${(widget.lastDate?.year ?? 2100)}",
                style:
                    widget
                        .pickerDecoration
                        ?.headerDecoration
                        ?.headerTextStyle ??
                    TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: 10),

            /// Grid of year options
            Expanded(
              child: GridView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: yearList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: (widget.width / 2.5) / (widget.height / 4),
                ),
                itemBuilder: (context, index) {
                  int year = (widget.firstDate?.year ?? 1900) + index;
                  final isSelected =
                      index == widget.currentDisplayDate.year - 1;
                  final isFocused = index == focusMonthIndex;

                  return Focus(
                    focusNode: monthFocusNodes[index],
                    child: InkWell(
                      hoverColor:
                          widget
                              .pickerDecoration
                              ?.monthDecoration
                              ?.hoverColor ??
                          Colors.transparent,
                      focusColor:
                          widget
                              .pickerDecoration
                              ?.monthDecoration
                              ?.focusColor ??
                          Colors.transparent,
                      onTap: () {
                        setState(() {
                          selectedYear = year;
                          widget.onDateChanged(
                            DateTime(selectedYear, selectedMonth, 1),
                          );
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: monthDecoration(isSelected, isFocused),
                        child: Center(
                          child: Text(
                            year.toString(),
                            style: monthStyle(isSelected, isFocused),
                          ),
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
    );
  }

  /// Returns the text style for each year tile.
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

  /// Returns the decoration for each year tile depending on focus/selection.
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
