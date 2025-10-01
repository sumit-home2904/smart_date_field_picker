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
      for (final n in yearFocusNodes) {
        // Remove any listeners to avoid multiple calls (defensive)
        try {
          n.removeListener(_focusListener);
        } catch (_) {}
        n.dispose();
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
      scrollController.hasClients
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
            final fallback =
                (idx >= 0 && idx < yearFocusNodes.length) ? idx : 0;
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
            final fallback =
                (idx >= 0 && idx < yearFocusNodes.length) ? idx : 0;
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
              alignment: widget.pickerDecoration?.headerTheme?.alignment ??
                  Alignment.center,
              margin: widget.pickerDecoration?.headerTheme?.headerMargin ??
                  EdgeInsets.zero,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                            widget.pickerDecoration?.pickerTheme?.hoverColor ??
                                Colors.transparent,
                        focusColor:
                            widget.pickerDecoration?.pickerTheme?.focusColor ??
                                Colors.transparent,
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
                          decoration: _yearTileDecoration(
                              context, isSelected, isFocused),
                          alignment: Alignment.center,
                          child: Text(
                            year.toString(),
                            style: _yearTileTextStyle(
                                context, isSelected, isFocused),
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

  BoxDecoration _yearTileDecoration(
      BuildContext context, bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.pickerTheme?.focusDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          );
    } else if (isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedDecoration ??
          BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
          );
    } else {
      return widget.pickerDecoration?.pickerTheme?.unSelectedDecoration ??
          BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.grey.shade300),
          );
    }
  }

  TextStyle _yearTileTextStyle(BuildContext context, bool isSelected, bool isFocused) {
    if (isFocused) {
      return widget.pickerDecoration?.pickerTheme?.focusTextStyle ??
          TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold);
    } else if (isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedTextStyle ??
          TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold);
    } else {
      return widget.pickerDecoration?.pickerTheme?.unSelectedTextStyle ??
          const TextStyle(color: Colors.black);
    }
  }
}
