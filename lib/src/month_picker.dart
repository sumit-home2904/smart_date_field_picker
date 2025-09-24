import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';

class MyMonthPicker extends StatefulWidget {
  final DateTime currentDisplayDate;
  final DateTime lastDate;
  final Function() changeToYearPicker;
  final Function(DateTime value) onDateChanged;
  final PickerDecoration? pickerDecoration;
  final double height;
  final double width;

  const MyMonthPicker({
    required this.width,
    required this.lastDate,
    required this.height,
    this.pickerDecoration,
    required this.onDateChanged,
    required this.currentDisplayDate,
    required this.changeToYearPicker,
    super.key,
  });

  @override
  State<MyMonthPicker> createState() => _MyMonthPickerState();
}

class _MyMonthPickerState extends State<MyMonthPicker> {
  static const double defaultRadius = 8.0;

  late List<FocusNode> monthFocusNodes;
  final FocusNode monthYearFocusNode = FocusNode();
  late int focusMonthIndex;
  late List<DateTime> monthsList;

  @override
  void initState() {
    super.initState();

    monthsList = List.generate(
      12,
      (i) => DateTime(widget.currentDisplayDate.year, i + 1, 1),
    );

    monthFocusNodes = List.generate(12, (_) => FocusNode());

    // find an initial enabled index: prefer current month if enabled,
    // otherwise nearest enabled month searching forward then backward
    final desired = (widget.currentDisplayDate.month - 1).clamp(0, 11);
    final initial = _nearestEnabledIndex(desired);
    focusMonthIndex = initial ?? desired; // if none found, fallback to desired

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // only request focus if the index is enabled
        if (_isMonthEnabled(focusMonthIndex)) {
          monthFocusNodes[focusMonthIndex].requestFocus();
        } else {
          // nothing enabled - leave header focusable
          monthYearFocusNode.requestFocus();
        }
      }
    });

    monthYearFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    for (final node in monthFocusNodes) node.dispose();
    monthYearFocusNode.dispose();
    super.dispose();
  }

  /// Check if a month should be disabled.
  /// Rules:
  /// 1) Allow months only up to currentDisplayDate.month (1..month)
  /// 2) Do not allow months after widget.lastDate (month-year inclusive)
  /// 3) Ensure the requested day exists in that month
  bool _isDisabledMonth(DateTime monthDate) {
    final monthNum = monthDate.month;
    final year = monthDate.year;

    // Rule 1: month must be <= currentDisplayDate.month
    if (monthNum > widget.lastDate.month) return true;

    // Rule 2: if month-year is after lastDate's month-year -> disabled
    if (year > widget.lastDate.year) return true;

    if (year == widget.lastDate.year && monthNum > widget.lastDate.month)
      return true;

    return false;
  }

  bool _isMonthEnabled(int index) {
    if (index < 0 || index >= monthsList.length) return false;
    return !_isDisabledMonth(monthsList[index]);
  }

  /// Find nearest enabled month index to 'start'. Searches outward (forward then backward).
  int? _nearestEnabledIndex(int start) {
    if (_isMonthEnabled(start)) return start;

    for (int d = 1; d < 12; d++) {
      final fwd = (start + d) % 12;
      if (_isMonthEnabled(fwd)) return fwd;
      final back = ((start - d) % 12 + 12) % 12;
      if (_isMonthEnabled(back)) return back;
    }
    return null;
  }

  /// Move focus; skip disabled months. direction can be positive/negative.
  void moveFocus(int newIndex) {
    if (!mounted) return;

    // Normalize newIndex within 0..11
    int idx = ((newIndex % 12) + 12) % 12;

    // If target is enabled, go straight; else step in the direction until find enabled.
    if (_isMonthEnabled(idx)) {
      setState(() {
        focusMonthIndex = idx;
      });
      monthFocusNodes[focusMonthIndex].requestFocus();
      return;
    }

    // Determine direction: +1 if moving forward overall, -1 if moving backward.
    final delta = (newIndex - focusMonthIndex) >= 0 ? 1 : -1;

    // Search up to 12 steps
    for (int i = 1; i <= 12; i++) {
      idx = ((idx + delta) % 12 + 12) % 12;
      if (_isMonthEnabled(idx)) {
        setState(() {
          focusMonthIndex = idx;
        });
        monthFocusNodes[focusMonthIndex].requestFocus();
        return;
      }
    }

    // If none found, do nothing (keep current focus)
  }

  int _getValidDay(int year, int month, int originalDay) {
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    return originalDay <= lastDayOfMonth ? originalDay : lastDayOfMonth;
  }

  void _onActivate() {
    if (monthYearFocusNode.hasFocus) {
      widget.changeToYearPicker();
      return;
    }

    if (focusMonthIndex >= 0 &&
        focusMonthIndex < 12 &&
        _isMonthEnabled(focusMonthIndex)) {
      final monthDate = monthsList[focusMonthIndex];
      final selectedMonth = monthDate.month;
      final selectedYear = monthDate.year;
      final adjustedDay = _getValidDay(
        selectedYear,
        selectedMonth,
        widget.currentDisplayDate.day,
      );
      widget.onDateChanged(
        DateTime(selectedYear, selectedMonth, adjustedDay),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = 3;
    final tileWidth = (widget.width - 20 - ((columns - 1) * 10)) / columns;
    final rows = 4;
    final tileHeight = (widget.height - 10 - 48 - ((rows - 1) * 10)) / rows;
    final childAspectRatio = tileWidth / (tileHeight <= 0 ? 1 : tileHeight);

    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.tab): () {
          if (monthYearFocusNode.hasFocus) {
            final idx = (widget.currentDisplayDate.month - 1).clamp(0, 11);
            final nearest = _nearestEnabledIndex(idx);
            if (nearest != null) {
              focusMonthIndex = nearest;
              FocusScope.of(context)
                  .requestFocus(monthFocusNodes[focusMonthIndex]);
            }
          } else {
            monthYearFocusNode.requestFocus();
          }
        },
        LogicalKeySet(LogicalKeyboardKey.arrowRight): () =>
            moveFocus(focusMonthIndex + 1),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): () =>
            moveFocus(focusMonthIndex - 1),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): () =>
            moveFocus(focusMonthIndex - 3),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
          if (monthYearFocusNode.hasFocus) {
            final idx = (widget.currentDisplayDate.month - 1).clamp(0, 11);
            final nearest = _nearestEnabledIndex(idx);
            if (nearest != null) {
              focusMonthIndex = nearest;
              FocusScope.of(context)
                  .requestFocus(monthFocusNodes[focusMonthIndex]);
            }
          } else {
            moveFocus(focusMonthIndex + 3);
          }
        },
        LogicalKeySet(LogicalKeyboardKey.enter): () => _onActivate(),
        LogicalKeySet(LogicalKeyboardKey.numpadEnter): () => _onActivate(),
        LogicalKeySet(LogicalKeyboardKey.select): () => _onActivate(),
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
                alignment: widget.pickerDecoration?.headerTheme?.alignment ??
                    Alignment.center,
                margin: widget.pickerDecoration?.headerTheme?.headerMargin ??
                    EdgeInsets.zero,
                padding: widget.pickerDecoration?.headerTheme?.headerPadding ??
                    EdgeInsets.all(10),
                decoration:
                    widget.pickerDecoration?.headerTheme?.boxDecoration ??
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
                    focusColor:
                        widget.pickerDecoration?.pickerTheme?.focusColor ??
                            Colors.white,
                    hoverColor:
                        widget.pickerDecoration?.pickerTheme?.hoverColor ??
                            Colors.white12,
                    borderRadius: BorderRadius.circular(
                        widget.pickerDecoration?.pickerTheme?.hoverRadius ??
                            defaultRadius),
                    onTap: () => widget.changeToYearPicker(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 6),
                      child: Text(
                        "Jan - Dec ${widget.currentDisplayDate.year}",
                        style: headerStyle(),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final monthDate = monthsList[index];
                    final isSelected =
                        index == widget.currentDisplayDate.month - 1;
                    final isFocused = index == focusMonthIndex;
                    final disabled = _isDisabledMonth(monthDate);

                    final textStyle = monthStyle(isSelected, isFocused);
                    final decoration = monthDecoration(isSelected, isFocused);

                    return Focus(
                      focusNode: monthFocusNodes[index],
                      canRequestFocus: !disabled,
                      child: InkWell(
                        onTap: disabled
                            ? null
                            : () {
                                final selectedMonth = monthDate.month;
                                final selectedYear = monthDate.year;
                                final adjustedDay = _getValidDay(
                                  selectedYear,
                                  selectedMonth,
                                  widget.currentDisplayDate.day,
                                );
                                widget.onDateChanged(
                                  DateTime(
                                      selectedYear, selectedMonth, adjustedDay),
                                );
                              },
                        borderRadius: BorderRadius.circular(
                            widget.pickerDecoration?.pickerTheme?.hoverRadius ??
                                defaultRadius),
                        hoverColor:
                            widget.pickerDecoration?.pickerTheme?.hoverColor ??
                                Colors.transparent,
                        focusColor:
                            widget.pickerDecoration?.pickerTheme?.focusColor ??
                                Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: disabled
                              ? decoration.copyWith(
                                  color: Colors.grey.withValues(alpha: 0.06),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                )
                              : decoration,
                          alignment: Alignment.center,
                          child: Semantics(
                            button: true,
                            enabled: !disabled,
                            selected: isSelected,
                            child: Text(
                              DateFormat.MMM().format(monthDate),
                              style: disabled
                                  ? textStyle.copyWith(color: Colors.grey)
                                  : textStyle,
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
      ),
    );
  }

  TextStyle monthStyle(bool isSelected, bool isFocused) {
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

  TextStyle headerStyle() {
    if (monthYearFocusNode.hasFocus) {
      return widget.pickerDecoration?.headerTheme?.focusTextStyle ??
          const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          );
    } else {
      return widget.pickerDecoration?.headerTheme?.headerTextStyle ??
          const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          );
    }
  }

  BoxDecoration monthDecoration(bool isSelected, bool isFocused) {
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
