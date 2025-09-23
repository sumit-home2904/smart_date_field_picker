/*
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

    if (widget.firstDate != oldWidget.firstDate ||
        widget.lastDate != oldWidget.lastDate) {
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
    final RenderBox? itemRenderBox = itemListKey[focusedIndex]
        .currentContext
        ?.findRenderObject() as RenderBox?;
    if (itemRenderBox == null) return;

    const int crossAxisCount =
        3; // Keep in sync with your GridView column count
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
      final double targetOffset =
          (focusedRow - maxVisibleRows + 1) * itemHeight;
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

          final fallbackIndex =
              (index >= 0 && index < monthFocusNodes.length) ? index : 0;

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
              alignment: widget.pickerDecoration?.headerTheme?.alignment ??
                  Alignment.center,
              margin: widget.pickerDecoration?.headerTheme?.headerMargin ??
                  EdgeInsets.zero,
              padding: widget.pickerDecoration?.headerTheme?.headerPadding ??
                  EdgeInsets.all(10),
              decoration: widget.pickerDecoration?.headerTheme?.boxDecoration ??
                  BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
              child: Text(
                "${(widget.firstDate.year)} - ${(widget.lastDate.year)}",
                style: widget.pickerDecoration?.headerTheme?.headerTextStyle ??
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Define desired item width
                  const double itemWidth = 90;

                  // Calculate how many items can fit
                  int crossAxisCount =
                      (constraints.maxWidth / itemWidth).floor().clamp(1, 10);

                  return GridView.builder(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    itemCount: yearList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio:
                          (widget.width / 2.5) / (widget.height / 4),
                    ),
                    itemBuilder: (context, index) {
                      int year = widget.firstDate.year + index;
                      final isSelected =
                          yearList[index] == widget.currentDisplayDate.year;
                      final isFocused = index == focusMonthIndex;

                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Material(
                          color: Colors.transparent,
                          child: Focus(
                            key: itemListKey[index],
                            focusNode: monthFocusNodes[index],
                            autofocus: focusedIndex == index,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(widget
                                      .pickerDecoration
                                      ?.pickerTheme
                                      ?.hoverRadius ??
                                  defaultRadius),
                              hoverColor: widget.pickerDecoration?.pickerTheme
                                      ?.hoverColor ??
                                  Colors.transparent,
                              focusColor: widget.pickerDecoration?.pickerTheme
                                      ?.focusColor ??
                                  Colors.transparent,
                              onTap: () {
                                setState(() {
                                  selectedYear = year;
                                  widget.onDateChanged(
                                      DateTime(selectedYear, selectedMonth, 1));
                                });
                              },
                              child: Container(
                                decoration:
                                    yearDecoration(isSelected, isFocused),
                                child: Center(
                                  child: Text(
                                    year.toString(),
                                    style: yearStyle(isSelected, isFocused),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Returns the text style for each year tile.
  TextStyle yearStyle(bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.pickerTheme?.focusTextStyle ??
          TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          );
    } else if (isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedTextStyle ??
          TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          );
    } else {
      return widget.pickerDecoration?.pickerTheme?.unSelectedTextStyle ??
          const TextStyle(color: Colors.black, fontWeight: FontWeight.normal);
    }
  }

  /// Returns the decoration for each year tile depending on focus/selection.
  BoxDecoration yearDecoration(bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.pickerTheme?.focusDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          );
    } else if (isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Theme.of(context).primaryColor),
          );
    } else {
      return widget.pickerDecoration?.pickerTheme?.unSelectedDecoration ??
          BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Colors.grey[300]!),
          );
    }
  }
}
*/



/*
// lib/src/year_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';

/// Year picker with per-tile focus, keyboard navigation and auto-scrolling.
class MyYearPicker extends StatefulWidget {
  final DateTime lastDate;
  final DateTime firstDate;
  final double width;
  final double height;
  final DateTime initialDate;
  final DateTime currentDisplayDate;
  final Function(DateTime time) onDateChanged;
  final PickerDecoration? pickerDecoration;

  const MyYearPicker({
    Key? key,
    required this.lastDate,
    required this.firstDate,
    required this.width,
    required this.height,
    required this.initialDate,
    required this.onDateChanged,
    required this.currentDisplayDate,
    this.pickerDecoration,
  }) : super(key: key);

  @override
  MyYearPickerState createState() => MyYearPickerState();
}

class MyYearPickerState extends State<MyYearPicker> {
  static const double defaultRadius = 8.0;

  late List<int> yearList;
  late List<FocusNode> yearFocusNodes;
  late List<GlobalKey> yearItemKeys;
  final ScrollController scrollController = ScrollController();

  /// index of currently focused tile
  int focusedIndex = -1;

  /// index of selected year (if needed)
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _generateYearsAndNodes();
    // initial focus is based on currentDisplayDate
    focusedIndex = yearList.indexOf(widget.currentDisplayDate.year);
    if (focusedIndex < 0) focusedIndex = 0;
    // selected index based on initialDate
    selectedIndex = yearList.indexOf(widget.initialDate.year);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusedIndex >= 0 && focusedIndex < yearFocusNodes.length) {
        yearFocusNodes[focusedIndex].requestFocus();
        _scrollToFocused();
      }
    });
  }

  void _generateYearsAndNodes() {
    yearList = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
          (i) => widget.firstDate.year + i,
    );

    // dispose old nodes if they exist
    if (mounted) {
      try {
        if (yearFocusNodes != null) {
          for (final n in yearFocusNodes) {
            n.dispose();
          }
        }
      } catch (_) {}
    }

    yearFocusNodes = List.generate(yearList.length, (_) => FocusNode());
    yearItemKeys = List.generate(yearList.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant MyYearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild year list and focus nodes if range changed
    if (oldWidget.firstDate != widget.firstDate ||
        oldWidget.lastDate != widget.lastDate) {
      _generateYearsAndNodes();

      // recalc indexes
      focusedIndex = yearList.indexOf(widget.currentDisplayDate.year);
      if (focusedIndex < 0) focusedIndex = 0;
      selectedIndex = yearList.indexOf(widget.initialDate.year);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (focusedIndex >= 0 && focusedIndex < yearFocusNodes.length) {
          yearFocusNodes[focusedIndex].requestFocus();
          _scrollToFocused();
        }
        setState(() {});
      });
    } else {
      // if currentDisplayDate changed, update focusedIndex to match (but only if not focused)
      final newIndex = yearList.indexOf(widget.currentDisplayDate.year);
      if (newIndex != -1 && newIndex != focusedIndex && !yearFocusNodes.any((n) => n.hasFocus)) {
        focusedIndex = newIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (focusedIndex >= 0 && focusedIndex < yearFocusNodes.length) {
            yearFocusNodes[focusedIndex].requestFocus();
            _scrollToFocused();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (final n in yearFocusNodes) {
      n.dispose();
    }
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToFocused() {
    if (focusedIndex < 0 || focusedIndex >= yearItemKeys.length) return;
    final ctx = yearItemKeys[focusedIndex].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 200),
        alignment: 0.5,
      );
    }
  }

  void _moveFocus(int newIndex) {
    if (yearFocusNodes.isEmpty) return;

    // wrap-around behavior
    if (newIndex < 0) newIndex = yearFocusNodes.length - 1;
    if (newIndex >= yearFocusNodes.length) newIndex = 0;

    setState(() {
      focusedIndex = newIndex;
    });

    yearFocusNodes[focusedIndex].requestFocus();
    _scrollToFocused();
  }

  void _onEnterPressed() {
    if (focusedIndex >= 0 && focusedIndex < yearList.length) {
      final int year = yearList[focusedIndex];
      final int month = widget.currentDisplayDate.month;
      final int day = widget.currentDisplayDate.day;
      final int maxDay = DateUtils.getDaysInMonth(year, month);
      final int clampedDay = day > maxDay ? maxDay : day;
      final selected = DateTime(year, month, clampedDay);
      widget.onDateChanged(selected);

      setState(() {
        selectedIndex = focusedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine crossAxisCount dynamically (keeps parity with your overlay width)
    const double itemWidth = 90.0;
    final int crossAxisCount = (widget.width / itemWidth).floor().clamp(1, 6);

    return CallbackShortcuts(
      bindings: {
        // Arrow navigation
        LogicalKeySet(LogicalKeyboardKey.arrowLeft):
            () => _moveFocus(focusedIndex - 1),
        LogicalKeySet(LogicalKeyboardKey.arrowRight):
            () => _moveFocus(focusedIndex + 1),
        LogicalKeySet(LogicalKeyboardKey.arrowUp):
            () => _moveFocus(focusedIndex - crossAxisCount),
        LogicalKeySet(LogicalKeyboardKey.arrowDown):
            () => _moveFocus(focusedIndex + crossAxisCount),

        // Enter -> select year
        LogicalKeySet(LogicalKeyboardKey.enter): _onEnterPressed,

        // Tab navigation: if none focused, focus currentDisplayDate-year; otherwise move forward
        LogicalKeySet(LogicalKeyboardKey.tab): () {
          if (!yearFocusNodes.any((n) => n.hasFocus)) {
            final idx = yearList.indexOf(widget.currentDisplayDate.year);
            final fallback = (idx >= 0 && idx < yearFocusNodes.length) ? idx : 0;
            focusedIndex = fallback;
            yearFocusNodes[focusedIndex].requestFocus();
            _scrollToFocused();
          } else {
            // move to next tile
            _moveFocus(focusedIndex + 1);
          }
        },

        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab): () {
          if (!yearFocusNodes.any((n) => n.hasFocus)) {
            final idx = yearList.indexOf(widget.currentDisplayDate.year);
            final fallback = (idx >= 0 && idx < yearFocusNodes.length) ? idx : 0;
            focusedIndex = fallback;
            yearFocusNodes[focusedIndex].requestFocus();
            _scrollToFocused();
          } else {
            _moveFocus(focusedIndex - 1);
          }
        },
      },
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Column(
          children: [
            // Header: only useful for year range; keep styling consistent with your decoration
            Container(
              width: widget.width,
              alignment:
              widget.pickerDecoration?.headerTheme?.alignment ?? Alignment.center,
              margin:
              widget.pickerDecoration?.headerTheme?.headerMargin ?? EdgeInsets.zero,
              padding: widget.pickerDecoration?.headerTheme?.headerPadding ??
                  const EdgeInsets.all(10),
              decoration: widget.pickerDecoration?.headerTheme?.boxDecoration ??
                  BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
              child: Text(
                "${widget.firstDate.year} - ${widget.lastDate.year}",
                style: widget.pickerDecoration?.headerTheme?.headerTextStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: 10),

            // Grid of years
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final int calcCrossAxisCount =
                (constraints.maxWidth / itemWidth).floor().clamp(1, 6);

                return GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: calcCrossAxisCount,
                    childAspectRatio: (widget.width / calcCrossAxisCount) /
                        (widget.height / 6), // reasonable tile aspect
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: yearList.length,
                  itemBuilder: (context, index) {
                    final year = yearList[index];
                    final isFocused = index == focusedIndex && yearFocusNodes[index].hasFocus;
                    final isSelected = index == selectedIndex;

                    return Focus(
                      key: yearItemKeys[index],
                      focusNode: yearFocusNodes[index],
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                            widget.pickerDecoration?.pickerTheme?.hoverRadius ??
                                defaultRadius),
                        hoverColor:
                        widget.pickerDecoration?.pickerTheme?.hoverColor ?? Colors.transparent,
                        focusColor:
                        widget.pickerDecoration?.pickerTheme?.focusColor ?? Colors.transparent,
                        onTap: () {
                          setState(() {
                            focusedIndex = index;
                            selectedIndex = index;
                          });
                          yearFocusNodes[index].requestFocus();
                          _scrollToFocused();

                          // Build a date with same month/day as currentDisplayDate,
                          // clamped to valid day in the chosen year
                          final month = widget.currentDisplayDate.month;
                          final day = widget.currentDisplayDate.day;
                          final maxDay = DateUtils.getDaysInMonth(year, month);
                          final clampedDay = day > maxDay ? maxDay : day;
                          final selected =
                          DateTime(year, month, clampedDay);

                          widget.onDateChanged(selected);
                        },
                        child: Container(
                          decoration: _yearTileDecoration(context, isSelected, isFocused),
                          alignment: Alignment.center,
                          child: Text(
                            year.toString(),
                            style: _yearTileTextStyle(context, isSelected, isFocused),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _yearTileDecoration(BuildContext context, bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.pickerTheme?.focusDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          );
    } else if (isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Theme.of(context).primaryColor),
          );
    } else {
      return widget.pickerDecoration?.pickerTheme?.unSelectedDecoration ??
          BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Colors.grey.shade300),
          );
    }
  }

  TextStyle _yearTileTextStyle(BuildContext context, bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.pickerTheme?.focusTextStyle ??
          TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold);
    } else if (isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedTextStyle ??
          TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold);
    } else {
      return widget.pickerDecoration?.pickerTheme?.unSelectedTextStyle ??
          const TextStyle(color: Colors.black);
    }
  }
}*/

/// 3 option

/*// lib/src/year_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';

class MyYearPicker extends StatefulWidget {
  final DateTime lastDate;
  final DateTime firstDate;
  final double width;
  final double height;
  final DateTime initialDate;
  final DateTime currentDisplayDate;
  final Function(DateTime time) onDateChanged;
  final PickerDecoration? pickerDecoration;

  const MyYearPicker({
    Key? key,
    required this.lastDate,
    required this.firstDate,
    required this.width,
    required this.height,
    required this.initialDate,
    required this.onDateChanged,
    required this.currentDisplayDate,
    this.pickerDecoration,
  }) : super(key: key);

  @override
  MyYearPickerState createState() => MyYearPickerState();
}

class MyYearPickerState extends State<MyYearPicker> {
  static const double defaultRadius = 8.0;

  late List<int> yearList;
  late List<FocusNode> yearFocusNodes;
  late List<GlobalKey> yearItemKeys;
  final ScrollController scrollController = ScrollController();

  int focusedIndex = -1; // currently focused tile index
  int selectedIndex = -1; // user's selected index (used when moving down from last row)

  @override
  void initState() {
    super.initState();
    _generateYearsAndNodes();

    // initial indices
    focusedIndex = yearList.indexOf(widget.currentDisplayDate.year);
    if (focusedIndex < 0) focusedIndex = 0;
    selectedIndex = yearList.indexOf(widget.initialDate.year);
    if (selectedIndex < 0) selectedIndex = focusedIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusedIndex >= 0 && focusedIndex < yearFocusNodes.length) {
        yearFocusNodes[focusedIndex].requestFocus();
        _scrollToIndex(focusedIndex);
      }
    });
  }

  void _generateYearsAndNodes() {
    yearList = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
          (i) => widget.firstDate.year + i,
    );

    // dispose old nodes if present
    try {
      if (yearFocusNodes != null) {
        for (final n in yearFocusNodes) {
          n.dispose();
        }
      }
    } catch (_) {}

    yearFocusNodes = List.generate(yearList.length, (_) => FocusNode());
    yearItemKeys = List.generate(yearList.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant MyYearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.firstDate != widget.firstDate ||
        oldWidget.lastDate != widget.lastDate) {
      _generateYearsAndNodes();
      focusedIndex = yearList.indexOf(widget.currentDisplayDate.year);
      if (focusedIndex < 0) focusedIndex = 0;
      selectedIndex = yearList.indexOf(widget.initialDate.year);
      if (selectedIndex < 0) selectedIndex = focusedIndex;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (focusedIndex >= 0 && focusedIndex < yearFocusNodes.length) {
          yearFocusNodes[focusedIndex].requestFocus();
          _scrollToIndex(focusedIndex);
        }
        setState(() {});
      });
    } else {
      // update focused if display date changed and nothing has focus
      final newIndex = yearList.indexOf(widget.currentDisplayDate.year);
      if (newIndex != -1 &&
          newIndex != focusedIndex &&
          !yearFocusNodes.any((n) => n.hasFocus)) {
        focusedIndex = newIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          yearFocusNodes[focusedIndex].requestFocus();
          _scrollToIndex(focusedIndex);
        });
      }
    }
  }

  @override
  void dispose() {
    for (final n in yearFocusNodes) {
      n.dispose();
    }
    scrollController.dispose();
    super.dispose();
  }

  /// Scroll to make `index` visible. Uses Scrollable.ensureVisible where possible.
  Future<void> _scrollToIndex(int index) async {
    if (index < 0 || index >= yearItemKeys.length) return;
    final ctx = yearItemKeys[index].currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 200),
        alignment: 0.5,
      );
      return;
    }

    // Fallback: compute approx offset using item height if context not ready.
    // (This fallback is conservative; ensure GridView tiles have keys so ensureVisible works.)
    final itemHeight = (widget.height - 60) / 6; // approximate rows = 6
    final rowsAbove = (index / 3).floor();
    final targetOffset = (rowsAbove * (itemHeight + 6)).clamp(
      0.0,
      scrollController.position.hasViewportDimension
          ? scrollController.position.maxScrollExtent
          : double.infinity,
    );
    if (scrollController.hasClients) {
      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Move focus to given index with wrap/scroll behavior.
  void _moveFocusTo(int newIndex, {required int crossAxisCount}) {
    if (yearFocusNodes.isEmpty) return;

    // Wrap-around behavior at edges
    if (newIndex < 0) {
      newIndex = yearFocusNodes.length - 1;
    } else if (newIndex >= yearFocusNodes.length) {
      newIndex = 0;
    }

    setState(() {
      focusedIndex = newIndex;
    });

    yearFocusNodes[focusedIndex].requestFocus();
    _scrollToIndex(focusedIndex);
  }

  /// Called for arrowDown — handles normal case and the special "last row -> user's index" case.
  void _onArrowDown(int crossAxisCount) {
    if (yearFocusNodes.isEmpty) return;

    // If nothing focused, focus current focusedIndex
    if (!yearFocusNodes.any((n) => n.hasFocus)) {
      yearFocusNodes[focusedIndex].requestFocus();
      _scrollToIndex(focusedIndex);
      return;
    }

    final int destination = focusedIndex + crossAxisCount;

    // If destination is within bounds, go there.
    if (destination < yearList.length) {
      focusedIndex = destination;
      yearFocusNodes[focusedIndex].requestFocus();
      _scrollToIndex(focusedIndex);
      setState(() {});
      return;
    }

    // Destination is outside (we are on the last row). Special behavior:
    // Move focus to the user's selected index (selectedIndex) if valid and different,
    // otherwise move to the last tile.
    final int targetIndex = (selectedIndex >= 0 && selectedIndex < yearList.length)
        ? selectedIndex
        : (yearList.length - 1);

    focusedIndex = targetIndex;
    yearFocusNodes[focusedIndex].requestFocus();
    _scrollToIndex(focusedIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const double itemWidth = 90.0;
    final int crossAxisCount = (widget.width / itemWidth).floor().clamp(1, 6);

    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.arrowLeft):
            () => _moveFocusTo(focusedIndex - 1, crossAxisCount: crossAxisCount),
        LogicalKeySet(LogicalKeyboardKey.arrowRight):
            () => _moveFocusTo(focusedIndex + 1, crossAxisCount: crossAxisCount),
        LogicalKeySet(LogicalKeyboardKey.arrowUp):
            () => _moveFocusTo(focusedIndex - crossAxisCount, crossAxisCount: crossAxisCount),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): () => _onArrowDown(crossAxisCount),
        LogicalKeySet(LogicalKeyboardKey.enter): () {
          if (focusedIndex >= 0 && focusedIndex < yearList.length) {
            final int year = yearList[focusedIndex];
            final int month = widget.currentDisplayDate.month;
            final int day = widget.currentDisplayDate.day;
            final int maxDay = DateUtils.getDaysInMonth(year, month);
            final int clampedDay = day > maxDay ? maxDay : day;
            final selected = DateTime(year, month, clampedDay);
            widget.onDateChanged(selected);
            setState(() {
              selectedIndex = focusedIndex;
            });
          }
        },

        // Tab behavior: focus enters grid at currentDisplayDate or cycles inside grid
        LogicalKeySet(LogicalKeyboardKey.tab): () {
          if (!yearFocusNodes.any((n) => n.hasFocus)) {
            final idx = yearList.indexOf(widget.currentDisplayDate.year);
            final fallback = (idx >= 0 && idx < yearFocusNodes.length) ? idx : 0;
            focusedIndex = fallback;
            yearFocusNodes[focusedIndex].requestFocus();
            _scrollToIndex(focusedIndex);
          } else {
            _moveFocusTo(focusedIndex + 1, crossAxisCount: crossAxisCount);
          }
        },

        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab): () {
          if (!yearFocusNodes.any((n) => n.hasFocus)) {
            final idx = yearList.indexOf(widget.currentDisplayDate.year);
            final fallback = (idx >= 0 && idx < yearFocusNodes.length) ? idx : 0;
            focusedIndex = fallback;
            yearFocusNodes[focusedIndex].requestFocus();
            _scrollToIndex(focusedIndex);
          } else {
            _moveFocusTo(focusedIndex - 1, crossAxisCount: crossAxisCount);
          }
        },
      },
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Column(
          children: [
            Container(
              width: widget.width,
              alignment:
              widget.pickerDecoration?.headerTheme?.alignment ?? Alignment.center,
              margin:
              widget.pickerDecoration?.headerTheme?.headerMargin ?? EdgeInsets.zero,
              padding: widget.pickerDecoration?.headerTheme?.headerPadding ??
                  const EdgeInsets.all(10),
              decoration: widget.pickerDecoration?.headerTheme?.boxDecoration ??
                  BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
              child: Text(
                "${widget.firstDate.year} - ${widget.lastDate.year}",
                style: widget.pickerDecoration?.headerTheme?.headerTextStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final int calcCrossAxisCount =
                (constraints.maxWidth / itemWidth).floor().clamp(1, 6);

                return GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: calcCrossAxisCount,
                    childAspectRatio: (widget.width / calcCrossAxisCount) /
                        (widget.height / 6),
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: yearList.length,
                  itemBuilder: (context, index) {
                    final year = yearList[index];
                    final isFocused = index == focusedIndex && yearFocusNodes[index].hasFocus;
                    final isSelected = index == selectedIndex;

                    return Focus(
                      key: yearItemKeys[index],
                      focusNode: yearFocusNodes[index],
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                            widget.pickerDecoration?.pickerTheme?.hoverRadius ??
                                defaultRadius),
                        hoverColor:
                        widget.pickerDecoration?.pickerTheme?.hoverColor ?? Colors.transparent,
                        focusColor:
                        widget.pickerDecoration?.pickerTheme?.focusColor ?? Colors.transparent,
                        onTap: () {
                          setState(() {
                            focusedIndex = index;
                            selectedIndex = index;
                          });
                          yearFocusNodes[index].requestFocus();
                          _scrollToIndex(index);

                          final month = widget.currentDisplayDate.month;
                          final day = widget.currentDisplayDate.day;
                          final maxDay = DateUtils.getDaysInMonth(year, month);
                          final clampedDay = day > maxDay ? maxDay : day;
                          final selected = DateTime(year, month, clampedDay);
                          widget.onDateChanged(selected);
                        },
                        child: Container(
                          decoration: _yearTileDecoration(context, isSelected, isFocused),
                          alignment: Alignment.center,
                          child: Text(
                            year.toString(),
                            style: _yearTileTextStyle(context, isSelected, isFocused),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _yearTileDecoration(BuildContext context, bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.pickerTheme?.focusDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          );
    } else if (isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Theme.of(context).primaryColor),
          );
    } else {
      return widget.pickerDecoration?.pickerTheme?.unSelectedDecoration ??
          BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Colors.grey.shade300),
          );
    }
  }

  TextStyle _yearTileTextStyle(BuildContext context, bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.pickerTheme?.focusTextStyle ??
          TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold);
    } else if (isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedTextStyle ??
          TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold);
    } else {
      return widget.pickerDecoration?.pickerTheme?.unSelectedTextStyle ??
          const TextStyle(color: Colors.black);
    }
  }
}*/


// lib/src/year_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';

class MyYearPicker extends StatefulWidget {
  final DateTime lastDate;
  final DateTime firstDate;
  final double width;
  final double height;
  final DateTime initialDate;
  final DateTime currentDisplayDate;
  final Function(DateTime time) onDateChanged;
  final PickerDecoration? pickerDecoration;

  const MyYearPicker({
    Key? key,
    required this.lastDate,
    required this.firstDate,
    required this.width,
    required this.height,
    required this.initialDate,
    required this.onDateChanged,
    required this.currentDisplayDate,
    this.pickerDecoration,
  }) : super(key: key);

  @override
  MyYearPickerState createState() => MyYearPickerState();
}

class MyYearPickerState extends State<MyYearPicker> {
  static const double defaultRadius = 8.0;

  late List<int> yearList;
  late List<FocusNode> yearFocusNodes;
  late List<GlobalKey> yearItemKeys;
  final ScrollController scrollController = ScrollController();

  int focusedIndex = -1; // currently focused tile index
  int selectedIndex = -1; // user's selected index

  @override
  void initState() {
    super.initState();
    _generateYearsAndNodes();

    // initial indices
    focusedIndex = yearList.indexOf(widget.currentDisplayDate.year);
    if (focusedIndex < 0) focusedIndex = 0;
    selectedIndex = yearList.indexOf(widget.initialDate.year);
    if (selectedIndex < 0) selectedIndex = focusedIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusedIndex >= 0 && focusedIndex < yearFocusNodes.length) {
        yearFocusNodes[focusedIndex].requestFocus();
        _scrollToIndex(focusedIndex);
      }
    });
  }

  void _generateYearsAndNodes() {
    yearList = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
          (i) => widget.firstDate.year + i,
    );

    // Dispose old nodes if present
    try {
      if (yearFocusNodes != null) {
        for (final n in yearFocusNodes) {
          // Remove any listeners to avoid multiple calls (defensive)
          try {
            n.removeListener(_focusListener);
          } catch (_) {}
          n.dispose();
        }
      }
    } catch (_) {}

    // yearFocusNodes = List.generate(yearList.length, (_) => FocusNode());
    // yearItemKeys = List.generate(yearList.length, (_) => GlobalKey());

    // Create new focus nodes and keys
    yearFocusNodes = List.generate(yearList.length, (_) => FocusNode());
    yearItemKeys = List.generate(yearList.length, (_) => GlobalKey());

    // Add listener to each focus node so UI updates when focus changes
    for (final node in yearFocusNodes) {
      node.addListener(_focusListener);
    }
  }

  /// Small shared listener that triggers rebuild on focus change.
  void _focusListener() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant MyYearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.firstDate != widget.firstDate ||
        oldWidget.lastDate != widget.lastDate) {
      _generateYearsAndNodes();
      focusedIndex = yearList.indexOf(widget.currentDisplayDate.year);
      if (focusedIndex < 0) focusedIndex = 0;
      selectedIndex = yearList.indexOf(widget.initialDate.year);
      if (selectedIndex < 0) selectedIndex = focusedIndex;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (focusedIndex >= 0 && focusedIndex < yearFocusNodes.length) {
          yearFocusNodes[focusedIndex].requestFocus();
          _scrollToIndex(focusedIndex);
        }
        setState(() {});
      });
    } else {
      // If display date changed and nothing has focus, update focusedIndex
      final newIndex = yearList.indexOf(widget.currentDisplayDate.year);
      if (newIndex != -1 &&
          newIndex != focusedIndex &&
          !yearFocusNodes.any((n) => n.hasFocus)) {
        focusedIndex = newIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          yearFocusNodes[focusedIndex].requestFocus();
          _scrollToIndex(focusedIndex);
        });
      }
    }
  }

  @override
  void dispose() {
    for (final n in yearFocusNodes) {
      try {
        n.removeListener(_focusListener);
      } catch (_) {}
      n.dispose();
    }
    scrollController.dispose();
    super.dispose();
  }

  /// Ensure the indexed tile is visible.
  Future<void> _scrollToIndex(int index) async {
    if (index < 0 || index >= yearItemKeys.length) return;
    final ctx = yearItemKeys[index].currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 200),
        alignment: 0.5,
      );
      return;
    }

    // Fallback (approx): compute by rows (used rarely)
    final approximateRows = 6;
    final itemHeight = (widget.height - 60) / approximateRows;
    final rowsAbove = (index / 3).floor();
    final targetOffset = (rowsAbove * (itemHeight + 6)).clamp(
      0.0,
      scrollController.hasClients ? scrollController.position.maxScrollExtent : double.infinity,
    );
    if (scrollController.hasClients) {
      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Compute grid geometry (crossAxisCount) based on width and layout constraints.
  int _calcCrossAxisCount(double width) {
    const double itemWidth = 90.0;
    return (width / itemWidth).floor().clamp(1, 6);
  }

  /// Helper to move focus to given index (wraps) and scroll.
  void _focusToIndex(int newIndex) {
    if (yearFocusNodes.isEmpty) return;

    // clamp/wrap
    if (newIndex < 0) newIndex = yearFocusNodes.length - 1;
    if (newIndex >= yearFocusNodes.length) newIndex = 0;

    setState(() {
      focusedIndex = newIndex;
    });

    yearFocusNodes[focusedIndex].requestFocus();
    _scrollToIndex(focusedIndex);
  }

  /// Arrow down behavior with last-row -> first-row same column mapping.
  void _handleArrowDown(int crossAxisCount) {
    if (yearFocusNodes.isEmpty) return;

    // If nothing focused, focus current
    if (!yearFocusNodes.any((n) => n.hasFocus)) {
      yearFocusNodes[focusedIndex].requestFocus();
      _scrollToIndex(focusedIndex);
      return;
    }

    final int col = focusedIndex % crossAxisCount;
    final int dest = focusedIndex + crossAxisCount;

    if (dest < yearList.length) {
      // Normal down
      _focusToIndex(dest);
      return;
    }

    // We are on last row — wrap to first row same column.
    int wrapped = col;
    // if wrapped index not valid (e.g., fewer columns in first row), clamp to last valid in first row
    if (wrapped >= yearList.length) wrapped = yearList.length - 1;
    _focusToIndex(wrapped);
  }

  /// Arrow up behavior with first-row -> last-row same column mapping.
  void _handleArrowUp(int crossAxisCount) {
    if (yearFocusNodes.isEmpty) return;

    if (!yearFocusNodes.any((n) => n.hasFocus)) {
      yearFocusNodes[focusedIndex].requestFocus();
      _scrollToIndex(focusedIndex);
      return;
    }

    final int col = focusedIndex % crossAxisCount;
    final int dest = focusedIndex - crossAxisCount;

    if (dest >= 0) {
      _focusToIndex(dest);
      return;
    }

    // We are on first row — wrap to last row same column.
    int lastRow = (yearList.length - 1) ~/ crossAxisCount;
    int wrapped = lastRow * crossAxisCount + col;

    // If wrapped index exceeds length (incomplete last row), step back rows until valid.
    while (wrapped >= yearList.length && lastRow > 0) {
      lastRow--;
      wrapped = lastRow * crossAxisCount + col;
    }
    // final clamp
    if (wrapped >= yearList.length) wrapped = yearList.length - 1;
    _focusToIndex(wrapped);
  }

  @override
  Widget build(BuildContext context) {
    const double itemWidth = 90.0;
    final int crossAxisCount = _calcCrossAxisCount(widget.width);

    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): () {
          // left: wrap to last if needed
          if (focusedIndex - 1 >= 0) {
            _focusToIndex(focusedIndex - 1);
          } else {
            _focusToIndex(yearList.length - 1);
          }
        },
        LogicalKeySet(LogicalKeyboardKey.arrowRight): () {
          // right: wrap to first if needed
          if (focusedIndex + 1 < yearList.length) {
            _focusToIndex(focusedIndex + 1);
          } else {
            _focusToIndex(0);
          }
        },
        LogicalKeySet(LogicalKeyboardKey.arrowUp): () =>
            _handleArrowUp(crossAxisCount),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): () =>
            _handleArrowDown(crossAxisCount),
        LogicalKeySet(LogicalKeyboardKey.enter): () {
          if (focusedIndex >= 0 && focusedIndex < yearList.length) {
            final int year = yearList[focusedIndex];
            final int month = widget.currentDisplayDate.month;
            final int day = widget.currentDisplayDate.day;
            final int maxDay = DateUtils.getDaysInMonth(year, month);
            final int clampedDay = day > maxDay ? maxDay : day;
            final selected = DateTime(year, month, clampedDay);
            widget.onDateChanged(selected);
            setState(() {
              selectedIndex = focusedIndex;
            });
          }
        },
        // Tab behavior (enter grid or iterate)
        LogicalKeySet(LogicalKeyboardKey.tab): () {
          if (!yearFocusNodes.any((n) => n.hasFocus)) {
            final idx = yearList.indexOf(widget.currentDisplayDate.year);
            final fallback = (idx >= 0 && idx < yearFocusNodes.length) ? idx : 0;
            focusedIndex = fallback;
            yearFocusNodes[focusedIndex].requestFocus();
            _scrollToIndex(focusedIndex);
          } else {
            _focusToIndex(focusedIndex + 1);
          }
        },
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab): () {
          if (!yearFocusNodes.any((n) => n.hasFocus)) {
            final idx = yearList.indexOf(widget.currentDisplayDate.year);
            final fallback = (idx >= 0 && idx < yearFocusNodes.length) ? idx : 0;
            focusedIndex = fallback;
            yearFocusNodes[focusedIndex].requestFocus();
            _scrollToIndex(focusedIndex);
          } else {
            _focusToIndex(focusedIndex - 1);
          }
        },
      },
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Column(
          children: [
            // Header
            Container(
              width: widget.width,
              alignment:
              widget.pickerDecoration?.headerTheme?.alignment ?? Alignment.center,
              margin:
              widget.pickerDecoration?.headerTheme?.headerMargin ?? EdgeInsets.zero,
              padding: widget.pickerDecoration?.headerTheme?.headerPadding ??
                  const EdgeInsets.all(10),
              decoration: widget.pickerDecoration?.headerTheme?.boxDecoration ??
                  BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
              child: Text(
                "${widget.firstDate.year} - ${widget.lastDate.year}",
                style: widget.pickerDecoration?.headerTheme?.headerTextStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: 10),

            // Grid
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final int calcCrossAxisCount =
                (constraints.maxWidth / itemWidth).floor().clamp(1, 6);

                return GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: calcCrossAxisCount,
                    childAspectRatio: (widget.width / calcCrossAxisCount) /
                        (widget.height / 6),
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: yearList.length,
                  itemBuilder: (context, index) {
                    final year = yearList[index];
                    final hasFocus = yearFocusNodes[index].hasFocus;
                    final isFocused = index == focusedIndex && hasFocus;
                    final isSelected = index == selectedIndex;

                    return Focus(
                      key: yearItemKeys[index],
                      focusNode: yearFocusNodes[index],
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                            widget.pickerDecoration?.pickerTheme?.hoverRadius ??
                                defaultRadius),
                        hoverColor:
                        widget.pickerDecoration?.pickerTheme?.hoverColor ?? Colors.transparent,
                        focusColor:
                        widget.pickerDecoration?.pickerTheme?.focusColor ?? Colors.transparent,
                        onTap: () {
                          setState(() {
                            focusedIndex = index;
                            selectedIndex = index;
                          });
                          yearFocusNodes[index].requestFocus();
                          _scrollToIndex(index);

                          final month = widget.currentDisplayDate.month;
                          final day = widget.currentDisplayDate.day;
                          final maxDay = DateUtils.getDaysInMonth(year, month);
                          final clampedDay = day > maxDay ? maxDay : day;
                          final selected = DateTime(year, month, clampedDay);
                          widget.onDateChanged(selected);
                        },
                        child: Container(
                          decoration: _yearTileDecoration(context, isSelected, isFocused),
                          alignment: Alignment.center,
                          child: Text(
                            year.toString(),
                            style: _yearTileTextStyle(context, isSelected, isFocused),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _yearTileDecoration(BuildContext context, bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.pickerTheme?.focusDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          );
    } else if (isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Theme.of(context).primaryColor),
          );
    } else {
      return widget.pickerDecoration?.pickerTheme?.unSelectedDecoration ??
          BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Colors.grey.shade300),
          );
    }
  }

  TextStyle _yearTileTextStyle(BuildContext context, bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.pickerTheme?.focusTextStyle ??
          TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold);
    } else if (isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedTextStyle ??
          TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold);
    } else {
      return widget.pickerDecoration?.pickerTheme?.unSelectedTextStyle ??
          const TextStyle(color: Colors.black);
    }
  }
}


