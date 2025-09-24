import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_date_field_picker/src/year_picker.dart';
import 'package:smart_date_field_picker/src/month_picker.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';

/// A FocusNode that never requests or accepts focus — used so disabled cells can't be focused.
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get canRequestFocus => false;
}

class OverlayBuilder extends StatefulWidget {
  /// Controller for showing or hiding the dropdown overlay.
  final OverlayPortalController controller;

  /// The offset to apply when positioning the dropdown overlay.
  final Offset? dropdownOffset;

  /// The layer link used to anchor the overlay to its originating widget.
  final LayerLink layerLink;

  /// Optional render box reference for layout calculations.
  final RenderBox? renderBox;

  /// The initially selected date.
  final DateTime? initialDate;

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// Customization options for the picker UI.
  final PickerDecoration? pickerDecoration;

  /// Controller for the input field associated with the picker.
  final TextEditingController textController;

  /// Callback triggered when a date is selected.
  final void Function(DateTime? value) onDateSelected;

  /// Creates an instance of [OverlayBuilder].
  const OverlayBuilder({
    super.key,
    this.renderBox,
    this.dropdownOffset,
    this.pickerDecoration,
    required this.lastDate,
    required this.firstDate,
    required this.layerLink,
    required this.controller,
    required this.initialDate,
    required this.onDateSelected,
    required this.textController,
  });

  @override
  State<OverlayBuilder> createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {

  /// When true -> align overlay to the right of anchor (so overlay appears to the left of anchor)
  bool displayOverlayLeft = false;

  /// whether overlay should align to anchor's right edge (i.e. place overlay to left)
  bool alignOverlayRightToAnchor = false;

  // measured overlay width and anchor position/width
  double? _measuredOverlayWidth;
  double? _anchorX;
  double? _anchorWidth;

  // padding from screen edges
  final double _screenPadding = 8.0;

  /// Controller for managing the text input in the date field.
  late TextEditingController _textController;

  /// Currently displayed month/year in the picker.
  late DateTime _currentDisplayDate;

  /// The date selected by the user.
  late DateTime selectedDate;

  /// Flag to control whether date view is visible.
  bool canShowDate = true;

  /// Flag to control whether year picker is visible.
  bool canShowYear = false;

  /// Flag to control whether month picker is visible.
  bool canShowMonth = false;

  /// Determines if the overlay appears below the field.
  bool displayOverlayBottom = true;

  /// Focus node for the left arrow button.
  FocusNode arrowLeftFocusNode = FocusNode();

  /// Focus node for the right arrow button.
  FocusNode arrowRightFocusNode = FocusNode();

  /// Focus node for the month/year display text.
  FocusNode monthYearFocusNode = FocusNode();

  /// Focus node for date cells in the calendar.
  FocusNode dateFocusNode = FocusNode();

  /// Keeps track of the currently focused date (for keyboard navigation).
  late DateTime focusSelectedDate;

  /// GlobalKey used for layout or positioning of UI element 1.
  final key1 = GlobalKey();

  /// GlobalKey used for layout or positioning of UI element 2.
  final key2 = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.initialDate != null) {
      _currentDisplayDate = widget.initialDate!;
      selectedDate = widget.initialDate!;
      focusSelectedDate = widget.initialDate!;
    } else {
      // take only year & month from lastDate, and set to last day of that month
      final year = widget.lastDate.year;
      final month = widget.lastDate.month;
      final day = widget.lastDate.day;
      final lastDay = DateTime(year, month,day); // gives last day of month
      _currentDisplayDate = lastDay;
      selectedDate = lastDay;
      focusSelectedDate = lastDay;
    }

    // Assign external text controller and listen for changes.
    _textController = widget.textController;
    _textController.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkRenderObjects();
    });



    // Rebuild when arrow buttons or header gains/loses focus.
    arrowLeftFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    arrowRightFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    monthYearFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    dateFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  /// Triggered when the user types in the text field.
  void _onTextChanged() {
    String text = widget.textController.text;
    DateTime? parsedDate = _parsePartialDate(text);

    if (parsedDate != null && _isValidDate(parsedDate)) {
      setState(() {
        _currentDisplayDate = parsedDate;
        focusSelectedDate = parsedDate;
      });
    }

    checkRenderObjects();
  }

  /// Attempts to parse a partial or complete date from input text.
  ///
  /// Accepts formats like:
  /// - `dd`
  /// - `dd/MM`
  /// - `dd/MM/yyyy`
  ///
  /// Handles 2-digit years by mapping them to 19xx or 20xx.
  DateTime? _parsePartialDate(String input) {
    if (input.isEmpty) return null;

    try {
      // Remove invalid characters.
      String cleanInput = input.replaceAll(RegExp(r'[^0-9/]'), '');
      List<String> parts = cleanInput.split('/');
      DateTime now = DateTime.now();

      if (parts.length == 1 && parts[0].isNotEmpty) {
        // Only day entered.
        int day = int.parse(parts[0]);
        if (day >= 1 && day <= 31) {
          return DateTime(now.year, now.month, day);
        }
      } else if (parts.length == 2 &&
          parts[0].isNotEmpty &&
          parts[1].isNotEmpty) {
        // Day and month entered.
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
          return DateTime(now.year, month, day);
        }
      } else if (parts.length == 3 &&
          parts[0].isNotEmpty &&
          parts[1].isNotEmpty &&
          parts[2].isNotEmpty) {
        // Full date entered.
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);

        // Normalize 2-digit year.
        if (year < 100) {
          year += (year < 50) ? 2000 : 1900;
        }

        if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
          return DateTime(year, month, day);
        }
      }

      // Fallback to strict parsing.
      return DateFormat("dd/MM/yyyy").parseStrict(input);
    } catch (e) {
      return null;
    }
  }

  /// Checks whether the overlay should be displayed above or below the anchor
  /// based on available screen space and platform constraints.

  void checkRenderObjects() {
    // Use provided anchor renderBox (from parent) if available, otherwise use key1
    final RenderBox? renderAnchor =
        widget.renderBox ?? (key1.currentContext?.findRenderObject() as RenderBox?);
    final RenderBox? renderOverlay =
    key2.currentContext?.findRenderObject() as RenderBox?;

    if (renderAnchor == null || renderOverlay == null) return;

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // anchor global pos & size
    final anchorGlobal = renderAnchor.localToGlobal(Offset.zero);
    final anchorX = anchorGlobal.dx;
    final anchorY = anchorGlobal.dy;
    final anchorW = renderAnchor.size.width;
    final anchorH = renderAnchor.size.height;

    // overlay measured width (prefer decoration width if set)
    final overlayW = widget.pickerDecoration?.width ?? renderOverlay.size.width;

    // save for use in setOffset
    _measuredOverlayWidth = overlayW;
    _anchorX = anchorX;
    _anchorWidth = anchorW;

    // Vertical: decide top or bottom as before (keep your existing logic)
    double availableBelow = screenHeight - (anchorY + anchorH);
    double availableAbove = anchorY;
    if (Platform.isAndroid || Platform.isIOS) {
      if (availableBelow < (screenHeight * 0.4) && availableAbove > availableBelow) {
        displayOverlayBottom = false;
      } else {
        displayOverlayBottom = true;
      }
    } else {
      if (availableBelow < renderOverlay.size.height && availableAbove > availableBelow) {
        displayOverlayBottom = false;
      } else {
        displayOverlayBottom = true;
      }
    }

    // Horizontal alignment logic you asked for:
    // 1) Default: left-align overlay so overlay.left == anchor.left
    // 2) If that would overflow right (anchorX + overlayW > screenWidth - padding)
    //    -> align overlay RIGHT edge to anchor RIGHT edge (so overlay shifts left)
    // 3) If left-aligned overlay would overflow left (anchorX < padding)
    //    -> align overlay LEFT to anchor left (but shift right to padding if overlay would go beyond)
    alignOverlayRightToAnchor = false; // default

    // Case: overlay would overflow right when left-aligned
    if (anchorX + overlayW + _screenPadding > screenWidth) {
      // align overlay right edge with anchor right edge
      alignOverlayRightToAnchor = true;
    } else if (anchorX < _screenPadding) {
      // anchor is very close to left edge; keep left-aligned but we'll shift overlay right slightly in setOffset
      alignOverlayRightToAnchor = false;
    } else {
      // normal: left-aligned
      alignOverlayRightToAnchor = false;
    }

    if (mounted) setState(() {});


  }



  /// Returns the offset for the overlay based on dropdownOffset and placement direction.
  Offset setOffset() {
    final defaultDx = widget.dropdownOffset?.dx ?? 0.0;
    final defaultDy = widget.dropdownOffset?.dy ?? 55.0;
    final dy = displayOverlayBottom ? defaultDy : -10.0;

    // If we measured overlay and anchor, compute precise dx
    if (_measuredOverlayWidth != null && _anchorX != null && _anchorWidth != null) {
      final overlayW = _measuredOverlayWidth!;
      final anchorX = _anchorX!;
      final anchorW = _anchorWidth!;

      // 1) If overlay should align its RIGHT edge to anchor's RIGHT edge:
      //    overlay.right == anchor.right
      //    offset dx relative to anchor.left = -(overlayW - anchorW)
      if (alignOverlayRightToAnchor) {
        double dx = defaultDx + -(overlayW - anchorW);
        // ensure we still keep small padding from screen edge
        if (anchorX + dx < _screenPadding - 1) {
          // If this would push overlay beyond left edge, clamp to padding
          dx = _screenPadding - anchorX;
        }
        return Offset(dx - 08, dy);
      }

      // 2) If overlay left-aligned would overflow left (anchorX < padding),
      //    shift overlay right so its left == padding
      if (anchorX + defaultDx < _screenPadding) {
        double shiftRight = _screenPadding - (anchorX + defaultDx);
        return Offset(defaultDx + shiftRight, dy);
      }

      // 3) Normal left-aligned case: overlay.left == anchor.left (plus any dropdownOffset.dx)
      return Offset(defaultDx, dy);
    }

    // Fallback before we measure: return a reasonable default
    return Offset(defaultDx != 0.0 ? defaultDx : 5.0, dy);
  }


  /// Builds the calendar/month picker header UI, including navigation arrows and month-year display.
  Widget _buildHeader() {
    return Container(
      alignment: widget.pickerDecoration?.headerTheme?.alignment,
      margin:
          widget.pickerDecoration?.headerTheme?.headerMargin ?? EdgeInsets.zero,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Left arrow button for navigating to the previous month.
          IconButton(
            focusNode: arrowLeftFocusNode,
            focusColor: widget.pickerDecoration?.pickerTheme?.focusColor ??
                Colors.white,
            hoverColor: widget.pickerDecoration?.pickerTheme?.hoverColor ??
                Colors.white12,
            icon: Icon(
              widget.pickerDecoration?.headerTheme?.iconDecoration?.leftIcon ??
                  Icons.chevron_left,
              size: widget
                  .pickerDecoration?.headerTheme?.iconDecoration?.leftIconSize,
              color: arrowLeftFocusNode.hasFocus
                  ? widget.pickerDecoration?.headerTheme?.iconDecoration
                          ?.leftFocusIconColor ??
                      Colors.black
                  : widget.pickerDecoration?.headerTheme?.iconDecoration
                          ?.leftIconColor ??
                      Colors.white,
            ),
            onPressed: _canNavigateToPreviousMonth() ? _previousMonth : null,
          ),

          Spacer(),

          /// Month-year display button to open month/year picker.
          Material(
            color: Colors.transparent,
            child: InkWell(
              focusNode: monthYearFocusNode,
              focusColor: widget.pickerDecoration?.pickerTheme?.focusColor ??
                  Colors.white,
              hoverColor: widget.pickerDecoration?.pickerTheme?.hoverColor ??
                  Colors.white12,
              borderRadius: BorderRadius.circular(
                  widget.pickerDecoration?.pickerTheme?.hoverRadius ??
                      defaultRadius),
              onTap: () {
                setState(() {
                  canShowDate = !canShowDate;
                  canShowMonth = true;
                  canShowYear = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  DateFormat('MMMM yyyy').format(_currentDisplayDate),
                  style: headerStyle(),
                ),
              ),
            ),
          ),

          Spacer(),

          /// Right arrow button for navigating to the next month.
          IconButton(
            focusNode: arrowRightFocusNode,
            focusColor: widget.pickerDecoration?.pickerTheme?.focusColor ??
                Colors.white,
            hoverColor: widget.pickerDecoration?.pickerTheme?.hoverColor ??
                Colors.white12,
            icon: Icon(
              widget.pickerDecoration?.headerTheme?.iconDecoration?.rightIcon ??
                  Icons.chevron_right,
              size: widget
                  .pickerDecoration?.headerTheme?.iconDecoration?.rightIconSize,
              color: arrowRightFocusNode.hasFocus
                  ? widget.pickerDecoration?.headerTheme?.iconDecoration
                          ?.rightFocusIconColor ??
                      Colors.black
                  : widget.pickerDecoration?.headerTheme?.iconDecoration
                          ?.rightIconColor ??
                      Colors.white,
            ),
            onPressed: _canNavigateToNextMonth() ? _nextMonth : null,
          ),
        ],
      ),
    );
  }

  /// Returns appropriate text style based on whether the month/year button is focused.
  TextStyle headerStyle() {
    if (monthYearFocusNode.hasFocus) {
      return widget.pickerDecoration?.headerTheme?.focusTextStyle ??
          TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          );
    } else {
      return widget.pickerDecoration?.headerTheme?.headerTextStyle ??
          TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          );
    }
  }

  /// Checks if user can navigate to the previous month based on `firstDate` constraint.
 /* bool _canNavigateToPreviousMonth() {
    DateTime firstOfMonth = DateTime(
      _currentDisplayDate.year,
      _currentDisplayDate.month,
      1,
    );
    DateTime firstOfPreviousMonth = DateTime(
      firstOfMonth.year,
      firstOfMonth.month - 1,
      1,
    );

    return !firstOfPreviousMonth.isBefore(
      DateTime(widget.firstDate.year, widget.firstDate.month, 1),
    );
  }*/


  bool _canNavigateToPreviousMonth() {
    final firstOfPreviousMonth = DateTime(
      _currentDisplayDate.year,
      _currentDisplayDate.month - 1,
      1,
    );

    final DateTime firstAllowedDay = DateTime(
      widget.firstDate.year,
      widget.firstDate.month,
      1,
    );

    return !firstOfPreviousMonth.isBefore(firstAllowedDay);
  }


  /// Navigates to the previous month and updates current and focused display dates.
  void _previousMonth() {
    if (_canNavigateToPreviousMonth()) {
      setState(() {
        focusSelectedDate = DateTime(
          _currentDisplayDate.year,
          _currentDisplayDate.month - 1,
          1,
        );
        _currentDisplayDate = DateTime(
          _currentDisplayDate.year,
          _currentDisplayDate.month - 1,
          1,
        );
      });
    }
  }


/*
  DateTime _normalizeLastDate(DateTime d) {
    // if caller only set year and left month/day as 1 (common when writing DateTime(2025)),
    // treat that as full year unless they explicitly passed month/day.
    if (d.month == 1 && d.day == 1 && d.hour == 0 && d.minute == 0 && d.second == 0) {
      return DateTime(d.year, 12, 31);
    }
    return d;
  }
*/




  /// Checks if user can navigate to the next month based on `lastDate` constraint.
  /// This compares the first day of the next month vs the LAST day of widget.lastDate's month.
  bool _canNavigateToNextMonth() {
    // First day of the next month relative to current display.
    final DateTime firstOfNextMonth = DateTime(
      _currentDisplayDate.year,
      _currentDisplayDate.month + 1,
      1,
    );

    // Last allowed day for the month of widget.lastDate.
    // DateTime(year, month + 1, 0) gives last day of (year, month).

    final DateTime lastAllowedDay = DateTime(
      widget.lastDate.year,
      widget.lastDate.month + 1,
      0,
    );

    // Allow navigation if the first day of next month is NOT after the last allowed day.
    return !firstOfNextMonth.isAfter(lastAllowedDay);
  }



  /// Navigates to the next month and updates current and focused display dates.
  void _nextMonth() {
    if (_canNavigateToNextMonth()) {
      setState(() {
        focusSelectedDate = DateTime(
          _currentDisplayDate.year,
          _currentDisplayDate.month + 1,
          1,
        );
        _currentDisplayDate = DateTime(
          _currentDisplayDate.year,
          _currentDisplayDate.month + 1,
          1,
        );
      });
    }
  }

  /// Returns a list of `DateTime`s to display in a calendar view for a given [month].
  /// It includes leading/trailing days to fill the first and last week completely.
  List<DateTime> getCalendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final startOffset = firstDayOfMonth.weekday % 7;
    final startDate = firstDayOfMonth.subtract(Duration(days: startOffset));

    final endOffset = 7 - (lastDayOfMonth.weekday % 7);
    final endDate = lastDayOfMonth.add(Duration(days: endOffset));

    List<DateTime> days = [];
    for (DateTime d = startDate;
        !d.isAfter(endDate);
        d = d.add(Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }

  /// Generates exactly 42 days for a 6-week calendar view grid,
  /// ensuring alignment with the current month display.
  List<DateTime> _generateCalendarDays() {
    final firstDayOfMonth = DateTime(
      _currentDisplayDate.year,
      _currentDisplayDate.month,
      1,
      0,
      0,
      0,
    );
    int daysBefore = firstDayOfMonth.weekday % 7;

    return List.generate(42, (index) {
      final date = firstDayOfMonth
          .subtract(Duration(days: daysBefore))
          .add(Duration(days: index));
      return DateTime(date.year, date.month, date.day, date.hour, 0, 0);
    });
  }

  /// Moves focus to the adjacent month and aligns focus to the correct weekday column.
  void moveFocusToAdjacentMonth(
    int direction,
    int currentIndex,
    DateTime targetMonth,
  ) {
    setState(() {
      _currentDisplayDate = targetMonth;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newMonthDays = _generateCalendarDays();
      int weekdayColumn = currentIndex % 7;
      final monthDates = newMonthDays
          .where((date) => date.month == _currentDisplayDate.month)
          .toList();

      DateTime selectedDate = direction < 0
          ? monthDates.lastWhere(
              (date) => date.weekday % 7 == weekdayColumn,
              orElse: () => monthDates.last,
            )
          : monthDates.firstWhere(
              (date) => date.weekday % 7 == weekdayColumn,
              orElse: () => monthDates.first,
            );

      setState(() {
        _currentDisplayDate = selectedDate;
        focusSelectedDate = selectedDate;
      });
    });
  }

  /// Moves focus horizontally to an adjacent month (left or right).
  void moveFocusLeftRightAdjacentMonth(
    int direction,
    int currentIndex,
    DateTime targetMonth,
  ) {
    setState(() {
      _currentDisplayDate = targetMonth;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DateTime selectedDate = direction < 0
          ? DateTime(targetMonth.year, targetMonth.month + 1, 0)
          : DateTime(targetMonth.year, targetMonth.month, 1);

      setState(() {
        _currentDisplayDate = DateTime(selectedDate.year, selectedDate.month);
        focusSelectedDate = selectedDate;
      });
    });
  }

  /// Builds the calendar grid view with keyboard navigation and focus management.
  Widget _buildCalendar() {
    final calendarDays = _generateCalendarDates();

    focusSelectedDate = DateTime(
      _currentDisplayDate.year,
      _currentDisplayDate.month,
      focusSelectedDate.day,
    );

    final currentIndex = calendarDays.indexWhere((d) {
      return DateFormat('yyyy-MM-dd').format(d) ==
          DateFormat('yyyy-MM-dd').format(focusSelectedDate);
    });

    final tabOrder = [
      arrowLeftFocusNode,
      monthYearFocusNode,
      arrowRightFocusNode,
      dateFocusNode,
    ];

    void handleTab({bool reverse = false}) {
      final currentFocusIndex = tabOrder.indexWhere((node) => node.hasFocus);
      if (currentFocusIndex != -1) {
        final nextIndex = reverse
            ? (currentFocusIndex - 1 + tabOrder.length) % tabOrder.length
            : (currentFocusIndex + 1) % tabOrder.length;
        tabOrder[nextIndex].requestFocus();
      }
    }

    return CallbackShortcuts(
      bindings: {
        /// Handle Enter key for selection and navigation
        LogicalKeySet(LogicalKeyboardKey.enter): () {
          if (arrowLeftFocusNode.hasFocus && _canNavigateToPreviousMonth()) {
            _previousMonth();
          } else if (arrowRightFocusNode.hasFocus && _canNavigateToNextMonth()) {
            _nextMonth();
          } else if (dateFocusNode.hasFocus) {
            widget.controller.hide();
            _selectDate(focusSelectedDate);
          }
        },

        /// Handle Tab navigation between elements
        LogicalKeySet(LogicalKeyboardKey.tab): () => handleTab(),
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab): () =>
            handleTab(reverse: true),

        /// Move left in calendar grid
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): () {
          dateFocusNode.requestFocus();
          if (dateFocusNode.hasFocus && currentIndex > 0) {
            final prevDate = calendarDays[currentIndex - 1];
            if (!prevDate.isBefore(widget.firstDate)) {
              setState(() {
                focusSelectedDate = prevDate;
                if (prevDate.month != _currentDisplayDate.month) {
                  _currentDisplayDate = DateTime(prevDate.year, prevDate.month);
                }
              });
            }
          } else {
            final prevMonth = DateTime(
              _currentDisplayDate.year,
              _currentDisplayDate.month - 1,
              1,
            );
            if (!prevMonth.isBefore(
              DateTime(
                widget.firstDate.year,
                widget.firstDate.month,
                1,
              ),
            )) {
              moveFocusLeftRightAdjacentMonth(-1, currentIndex, prevMonth);
            }
          }
        },

        /// Move right in calendar grid
        LogicalKeySet(LogicalKeyboardKey.arrowRight): () {
          dateFocusNode.requestFocus();
          if (dateFocusNode.hasFocus &&
              currentIndex < calendarDays.length - 1) {
            final nextDate = calendarDays[currentIndex + 1];
            if (!nextDate.isAfter(widget.lastDate)) {
              setState(() {
                focusSelectedDate = nextDate;
                if (nextDate.month != _currentDisplayDate.month) {
                  _currentDisplayDate = DateTime(nextDate.year, nextDate.month);
                }
              });
            }
          } else {
            final nextMonth = DateTime(
              _currentDisplayDate.year,
              _currentDisplayDate.month + 1,
              1,
            );
            if (!nextMonth.isAfter(
              DateTime(widget.lastDate.year, 12, 31),
            )) {
              moveFocusLeftRightAdjacentMonth(1, currentIndex, nextMonth);
            }
          }
        },

        /// Move up by one week
        LogicalKeySet(LogicalKeyboardKey.arrowUp): () {
          dateFocusNode.requestFocus();
          if (dateFocusNode.hasFocus) {
            int targetIndex = currentIndex - 7;
            if (targetIndex >= 0) {
              final targetDate = calendarDays[targetIndex];
              if (!targetDate.isBefore(widget.firstDate)) {
                setState(() {
                  focusSelectedDate = targetDate;
                  if (targetDate.month != _currentDisplayDate.month ||
                      targetDate.year != _currentDisplayDate.year) {
                    _currentDisplayDate = DateTime(
                      targetDate.year,
                      targetDate.month,
                    );
                  }
                });
              }
            } else {
              final prevMonth = DateTime(
                _currentDisplayDate.year,
                _currentDisplayDate.month - 1,
                1,
              );
              if (!prevMonth.isBefore(
                DateTime(
                  widget.firstDate.year,
                  widget.firstDate.month,
                  1,
                ),
              )) {
                moveFocusToAdjacentMonth(-1, currentIndex, prevMonth);
              }
            }
          }
        },

        /// Move down by one week
        LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
          dateFocusNode.requestFocus();
          if (dateFocusNode.hasFocus &&
              currentIndex + 7 < calendarDays.length) {
            final targetDate = calendarDays[currentIndex + 7];
            if (!targetDate.isAfter(widget.lastDate)) {
              setState(() {
                focusSelectedDate = targetDate;
                if (targetDate.month != _currentDisplayDate.month) {
                  _currentDisplayDate = DateTime(
                    targetDate.year,
                    targetDate.month,
                  );
                }
              });
            }
          } else {
            final nextMonth = DateTime(
              _currentDisplayDate.year,
              _currentDisplayDate.month + 1,
              1,
            );
            final lastAllowedDate = DateTime(
              widget.lastDate.year,
              12,
              31,
            );
            if (!nextMonth.isAfter(lastAllowedDate)) {
              moveFocusToAdjacentMonth(1, currentIndex, nextMonth);
            }
          }
        },
      },
      child: Column(
        children: [
          _buildWeekdayHeaders(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              physics: ClampingScrollPhysics(),
              children: List.generate(calendarDays.length, (index) {
                final date = calendarDays[index];
                final isCurrentMonth = date.month == _currentDisplayDate.month;
                final isSelected = date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;

                // NEW: consider date disabled if outside allowed range
                final bool isDisabled = date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);

                // Focus logic: only show focus if this date is the focused date AND it's not disabled
                final isFocusDate = !isDisabled &&
                    date.year == focusSelectedDate.year &&
                    date.month == focusSelectedDate.month &&
                    date.day == focusSelectedDate.day &&
                    dateFocusNode.hasFocus;

                return Material(
                  color: Colors.transparent,
                  child: Focus(
                    focusNode: isDisabled ? AlwaysDisabledFocusNode() : dateFocusNode,
                    child: InkWell(
                      focusColor:
                      widget.pickerDecoration?.pickerTheme?.focusColor ??
                          Colors.white,
                      hoverColor:
                      widget.pickerDecoration?.pickerTheme?.hoverColor ??
                          Colors.white12,
                      borderRadius: BorderRadius.circular(
                          widget.pickerDecoration?.pickerTheme?.hoverRadius ??
                              defaultRadius),
                      // Disable tapping for out-of-range dates
                      onTap: isDisabled
                          ? null
                          : () {
                        setState(() {
                          focusSelectedDate = date;
                        });
                        _selectDate(date);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: dayDecoration(
                          isCurrentMonth,
                          isFocusDate,
                          isSelected,
                          isDisabled, // <-- pass disabled flag
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: dayTextStyle(
                            isCurrentMonth,
                            isFocusDate,
                            isSelected,
                            isDisabled, // <-- pass disabled flag
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the decoration for each day cell based on its state (selected, focused, etc.).
  // BoxDecoration dayDecoration(bool isCurrentMonth, bool isFocusDate, bool isSelected,) {
  //   // If the current date is also focused → show focusDecoration
  //   if (isFocusDate) {
  //     return widget.pickerDecoration?.pickerTheme?.focusDecoration ??
  //         BoxDecoration(
  //           color: Colors.transparent,
  //           borderRadius: BorderRadius.circular(6),
  //           border: Border.all(color: Theme.of(context).primaryColor),
  //         );
  //   }
  //
  //   // Selected date in current month
  //   if (isCurrentMonth && isSelected) {
  //     return widget.pickerDecoration?.pickerTheme?.selectedDecoration ??
  //         BoxDecoration(
  //           color: Theme.of(context).primaryColor,
  //           borderRadius: BorderRadius.circular(6),
  //         );
  //   }
  //
  //   // Unselected date outside current month
  //   if (!isCurrentMonth && !isSelected) {
  //     return widget.pickerDecoration?.pickerTheme?.unSelectedDecoration ??
  //         BoxDecoration(
  //           color: Colors.transparent,
  //           borderRadius: BorderRadius.circular(6),
  //         );
  //   }
  //
  //   return BoxDecoration();
  // }
  //
  // /// Returns the text style for day numbers based on their state.
  // TextStyle dayTextStyle(bool isCurrentMonth, bool isFocusDate, bool isSelected,) {
  //   // Focus takes highest priority (even if it's the current date or selected)
  //   if (isFocusDate) {
  //     return widget.pickerDecoration?.pickerTheme?.focusTextStyle ??
  //         TextStyle(color: Theme.of(context).primaryColor);
  //   }
  //
  //   // Selected date in current month
  //   if (isCurrentMonth && isSelected) {
  //     return widget.pickerDecoration?.pickerTheme?.selectedTextStyle ??
  //         TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  //   }
  //
  //   // Unselected date in current month
  //   if (isCurrentMonth) {
  //     return widget.pickerDecoration?.pickerTheme?.unSelectedTextStyle ??
  //         TextStyle(color: Colors.black);
  //   }
  //
  //   // Disabled (dates outside current month)
  //   return widget.pickerDecoration?.pickerTheme?.disableTextStyle ??
  //       TextStyle(color: Colors.grey);
  // }

  BoxDecoration dayDecoration(
      bool isCurrentMonth,
      bool isFocusDate,
      bool isSelected,
      bool isDisabled,
      ) {
    // Disabled state highest priority for decoration
    if (isDisabled) {
      return widget.pickerDecoration?.pickerTheme?.disableDecoration ??
          BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          );
    }
    // If the current date is also focused → show focusDecoration
    if (isFocusDate) {
      return widget.pickerDecoration?.pickerTheme?.focusDecoration ??
          BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Theme.of(context).primaryColor),
          );
    }

    // Selected date in current month
    if (isCurrentMonth && isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedDecoration ??
          BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(6),
          );
    }

    // Unselected date outside current month
    if (!isCurrentMonth && !isSelected) {
      return widget.pickerDecoration?.pickerTheme?.unSelectedDecoration ??
          BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          );
    }

    return widget.pickerDecoration?.pickerTheme?.currentMonthDecoration ??
        BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        );
  }



  TextStyle dayTextStyle(
      bool isCurrentMonth,
      bool isFocusDate,
      bool isSelected,
      bool isDisabled,
      ) {


    // Disabled highest priority
    if (isDisabled) {
      return widget.pickerDecoration?.pickerTheme?.disableTextStyle ??
          TextStyle(color: Colors.grey);
    }

    // Focused state
    if (isFocusDate) {
      return widget.pickerDecoration?.pickerTheme?.focusTextStyle ??
          TextStyle(color: Theme.of(context).primaryColor);
    }

    // Selected in current month
    if (isCurrentMonth && isSelected) {
      return widget.pickerDecoration?.pickerTheme?.selectedTextStyle ??
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
    }

    // Unselected and outside current month
    if (!isCurrentMonth && !isSelected) {
      return widget.pickerDecoration?.pickerTheme?.unSelectedTextStyle ??
          TextStyle(color: Colors.grey);
    }

    // Default fallback (treat as unselected current-month)
    return widget.pickerDecoration?.pickerTheme?.currentMothTextStyle ??
        TextStyle(color: Colors.black);
  }


  /// Builds headers for weekdays (Mon, Tue, etc.) aligned with the calendar grid.
  Widget _buildWeekdayHeaders() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(7, (index) {
          String weekday = DateFormat('E').format(DateTime(2021, 1, 4 + index));
          return Expanded(
            child: Center(
              child: Text(
                weekday,
                style: widget.pickerDecoration?.weekTextStyle ??
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Generates the calendar grid dates based on [focusSelectedDate].
  /// Includes leading and trailing days to complete full weeks.
  List<DateTime> _generateCalendarDates() {
    DateTime firstDayOfMonth = DateTime(
      focusSelectedDate.year,
      focusSelectedDate.month,
      1,
    );
    DateTime lastDayOfMonth = DateTime(
      focusSelectedDate.year,
      focusSelectedDate.month + 1,
      0,
    );
    int daysInMonth = lastDayOfMonth.day;
    int firstWeekday = firstDayOfMonth.weekday % 7;

    List<DateTime> calendarDates = [];

    // Add previous month's trailing days to align first week
    for (int i = firstWeekday - 1; i >= 0; i--) {
      calendarDates.add(firstDayOfMonth.subtract(Duration(days: i + 1)));
    }

    // Add current month days
    for (int day = 1; day <= daysInMonth; day++) {
      calendarDates.add(
        DateTime(focusSelectedDate.year, focusSelectedDate.month, day),
      );
    }

    // Add next month's leading days to complete last week
    while (calendarDates.length % 7 != 0) {
      calendarDates.add(calendarDates.last.add(const Duration(days: 1)));
    }

    return calendarDates;
  }

  /// Checks if the given [date] is within the allowed [firstDate] and [lastDate] range.
  bool _isValidDate(DateTime date) {
    if (date.isBefore(widget.firstDate)) {
      return false;
    }
    if (date.isAfter(widget.lastDate)) return false;
    return true;
  }

  /// Updates the selected date in the controller and triggers [onDateSelected] callback.
  void _selectDate(DateTime date) {
    setState(() {
      widget.textController.text = DateFormat("dd/MM/yyyy").format(date);
    });
    widget.onDateSelected.call(date);
  }

  /// Builds the complete calendar/date picker popup widget.
  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      link: widget.layerLink,
      offset: setOffset(),
      followerAnchor: displayOverlayBottom
          ? (displayOverlayLeft ? Alignment.topRight : Alignment.topLeft)
          : (displayOverlayLeft ? Alignment.bottomRight : Alignment.bottomLeft),
      child: LayoutBuilder(
        builder: (context, c) {
          return Container(
            key: key1,
            height: widget.pickerDecoration?.height ?? 330,
            decoration: widget.pickerDecoration?.menuDecoration ??
                BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
            child: SizedBox(
              key: key2,
              height: widget.pickerDecoration?.height ?? 330,
              width: widget.pickerDecoration?.width ?? 270,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canShowDate) _buildHeader(),
                  if (canShowDate) Expanded(child: _buildCalendar()),
                  if (canShowMonth && !canShowYear)
                    Expanded(
                      child: MyMonthPicker(
                        pickerDecoration: widget.pickerDecoration,
                        lastDate: widget.lastDate,
                        width: widget.pickerDecoration?.width ?? 270,
                        height: widget.pickerDecoration?.height ?? 320,
                        currentDisplayDate: focusSelectedDate,
                        changeToYearPicker: () {
                          setState(() {
                            canShowYear = true;
                          });
                        },
                        onDateChanged: (date) {
                          setState(() {
                            _currentDisplayDate = date;
                            focusSelectedDate = date;
                            dateFocusNode.requestFocus();
                            canShowMonth = false;
                            canShowDate = true;
                          });
                        },
                      ),
                    ),
                  if (canShowYear)
                    Expanded(
                      child: MyYearPicker(
                        lastDate: widget.lastDate,
                        firstDate: widget.firstDate,
                        initialDate: _currentDisplayDate,
                        currentDisplayDate: _currentDisplayDate,
                        pickerDecoration: widget.pickerDecoration,
                        width: widget.pickerDecoration?.width ?? 270,
                        height: widget.pickerDecoration?.height ?? 320,
                        onDateChanged: (date) {
                          setState(() {
                            _currentDisplayDate = date;
                            focusSelectedDate = date;
                            canShowYear = false;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Cleans up focus nodes and listeners when the widget is removed from the tree.
  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    dateFocusNode.dispose();
    monthYearFocusNode.dispose();
    arrowRightFocusNode.dispose();
    arrowLeftFocusNode.dispose();
    super.dispose();
  }
}
