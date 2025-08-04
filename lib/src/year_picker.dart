import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';

/// A customizable year picker widget with keyboard navigation and styling support.
/// Used for selecting a year within a range from [firstDate] to [lastDate].
class MyYearPicker extends StatefulWidget {
  /// The last selectable date.
  final DateTime lastDate;

  /// The first selectable date.
  final DateTime firstDate;

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
    required this.lastDate,
    required this.firstDate,
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
  int focusMonthIndex = -1;

  /// Currently selected year.
  late int selectedYear;

  /// Currently selected month.
  late int selectedMonth;

  /// List of all years between [firstDate] and [lastDate].
  List<int> yearList = [];

  late List<GlobalKey> itemListKey = [];

  @override
  void initState() {
    super.initState();

    yearList = List.generate(
      (widget.lastDate.year) - (widget.firstDate.year) + 1,
          (i) => (widget.firstDate.year) + i,
    );

    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;

    int startYear = widget.firstDate.year;
    int endYear = widget.lastDate.year;
    int totalYears = endYear - startYear + 1;

    monthFocusNodes = List.generate(totalYears, (_) => FocusNode());
    itemListKey = List.generate(totalYears, (_) => GlobalKey());

    // Wait for layout and then scroll to focused year
    WidgetsBinding.instance.addPostFrameCallback((_) {

      focusMonthIndex = widget.currentDisplayDate.year - startYear;
      focusedIndex = focusMonthIndex;

      monthFocusNodes[focusMonthIndex].requestFocus();
      scrollToFocusedItem();

      setState(() {});
    });

    scrollController.addListener(() {
      if (monthFocusNodes[focusedIndex].hasFocus == false &&
          focusedIndex >= 0 &&
          focusedIndex < monthFocusNodes.length) {
        monthFocusNodes[focusedIndex].requestFocus();
      }
    });
  }

  /// Recalculates year list and focus nodes when widget updates.
  @override
  void didUpdateWidget(covariant MyYearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.firstDate != oldWidget.firstDate || widget.lastDate != oldWidget.lastDate) {
      yearList = List.generate(
        (widget.lastDate.year) - (widget.firstDate.year) + 1,
            (i) => (widget.firstDate.year) + i,
      );

      selectedYear = widget.initialDate.year;
      selectedMonth = widget.initialDate.month;

      int startYear = widget.firstDate.year;
      int endYear = widget.lastDate.year;
      int totalYears = endYear - startYear + 1;

      monthFocusNodes = List.generate(totalYears, (_) => FocusNode());

      focusMonthIndex = widget.currentDisplayDate.year - startYear;
      focusedIndex = focusMonthIndex;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        monthFocusNodes[focusMonthIndex].requestFocus();
        scrollToFocusedItem();
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
        focusedIndex = newIndex;
        monthFocusNodes[focusMonthIndex].requestFocus();
      });

    } else {
      // Loop focus if it overflows
      if (newIndex == totalYears) {
        setState(() {
          focusedIndex = 0;
          focusMonthIndex = 0;
          monthFocusNodes[focusMonthIndex].requestFocus();
        });
      }
      if (newIndex == -1) {
        setState(() {
          focusedIndex = -1;
          focusMonthIndex = totalYears - 1;
          monthFocusNodes[focusMonthIndex].requestFocus();
        });
      }
    }

    scrollToFocusedItem();
  }

  int focusedIndex = -1;
  final ScrollController scrollController = ScrollController();

  void scrollToFocusedItem() {
    final RenderBox? itemRenderBox = itemListKey[focusedIndex].currentContext?.findRenderObject() as RenderBox?;
    if (itemRenderBox == null) return;

    const int crossAxisCount = 3; // Keep in sync with your GridView column count
    final double itemHeight = itemRenderBox.size.height;
    final double viewHeight = widget.height;

    // Total visible rows in the grid
    final int maxVisibleRows = (viewHeight / itemHeight).floor();

    // Current focused item's row index
    final int focusedRow = focusedIndex ~/ crossAxisCount;

    // Calculate first and last visible rows
    final double currentScrollOffset = scrollController.offset;
    final double firstVisibleRow = currentScrollOffset / itemHeight;
    final double lastVisibleRow = firstVisibleRow + maxVisibleRows - 1;

    // Scroll if focused row is outside visible range
    if (focusedRow > lastVisibleRow) {
      final double targetOffset = (focusedRow - maxVisibleRows + 1) * itemHeight;
      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    } else if (focusedRow < firstVisibleRow) {
      final double targetOffset = focusedRow * itemHeight;

      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        /// Tab key toggles focus on the grid.
        LogicalKeySet(LogicalKeyboardKey.tab): () {
          final currentYear = widget.currentDisplayDate.year;
          final startYear = widget.firstDate.year;
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
                "${(widget.firstDate.year)} - ${(widget.lastDate.year)}",
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
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                itemCount: yearList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: (widget.width / 2.5) / (widget.height / 4),
                ),
                itemBuilder: (context, index) {
                  int year = (widget.firstDate.year) + index;
                  final isSelected =
                      index == widget.currentDisplayDate.year - 1;
                  final isFocused = index == focusMonthIndex;

                  return Focus(
                    key:  itemListKey[index],
                    focusNode: monthFocusNodes[index],
                    autofocus: focusedIndex == index,
                    child: InkWell(
                      hoverColor:
                          widget
                              .pickerDecoration
                              ?.yearDecoration
                              ?.hoverColor ??
                          Colors.transparent,
                      focusColor:
                          widget
                              .pickerDecoration
                              ?.yearDecoration
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
                        decoration: yearDecoration(isSelected, isFocused),
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
      return widget.pickerDecoration?.yearDecoration?.disableTextStyle ??
          TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.normal,
          );
    } else if (isSelected) {
      return widget.pickerDecoration?.yearDecoration?.selectedTextStyle ??
          TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          );
    } else {
      return widget.pickerDecoration?.yearDecoration?.unSelectedTextStyle ??
          const TextStyle(color: Colors.black, fontWeight: FontWeight.normal);
    }
  }

  /// Returns the decoration for each year tile depending on focus/selection.
  BoxDecoration yearDecoration(bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.yearDecoration?.focusDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          );
    } else if (isSelected) {
      return widget.pickerDecoration?.yearDecoration?.selectedDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor),
          );
    } else {
      return widget.pickerDecoration?.yearDecoration?.unSelectedDecoration ??
          BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          );
    }
  }
}
