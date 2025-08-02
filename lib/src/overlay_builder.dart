import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_date_field_picker/src/year_picker.dart';
import 'package:smart_date_field_picker/src/month_picker.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';

class OverlayBuilder extends StatefulWidget {

  /// Controller for showing or hiding the dropdown overlay.
  final OverlayPortalController controller;
  final Offset? dropdownOffset;
  final LayerLink layerLink;
  final RenderBox? renderBox;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final PickerDecoration? pickerDecoration;
  final TextEditingController textController;
  final void Function(DateTime? value) onDateSelected;

  OverlayBuilder({
    super.key,
    this.lastDate,
    this.renderBox,
    this.firstDate,
    this.dropdownOffset,
    this.pickerDecoration,
    required this.controller,
    required this.layerLink,
    required this.initialDate,
    required this.onDateSelected,
    required this.textController,
  });

  @override
  State<OverlayBuilder> createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  late TextEditingController _textController;

  late DateTime _currentDisplayDate;
  late DateTime selectedDate;

  bool canShowDate = true;
  bool canShowYear = false;
  bool canShowMonth = false;
  bool displayOverlayBottom = true;

  FocusNode arrowLeftFocusNode = FocusNode(); // Focus for the left arrow button
  FocusNode arrowRightFocusNode = FocusNode(); // Focus for the right arrow button

  FocusNode monthYearFocusNode = FocusNode(); // Focus for the month/year text
  FocusNode dateFocusNode = FocusNode(); // Focus for individual date cells

  // The date currently focused (for keyboard navigation)
  late DateTime focusSelectedDate;

  final key1 = GlobalKey(), key2 = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentDisplayDate = widget.initialDate ?? DateTime.now();
    selectedDate = widget.initialDate ?? DateTime.now();
    focusSelectedDate = widget.initialDate ?? DateTime.now();
    _textController = widget.textController;
    _textController.addListener(_onTextChanged);

    arrowLeftFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    arrowRightFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    monthYearFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

  }

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

  DateTime? _parsePartialDate(String input) {
    if (input.isEmpty) return null;

    try {
      // Remove any non-digit or slash characters
      String cleanInput = input.replaceAll(RegExp(r'[^0-9/]'), '');

      List<String> parts = cleanInput.split('/');
      DateTime now = DateTime.now();

      if (parts.length == 1 && parts[0].isNotEmpty) {
        // Only day entered (e.g., "23")
        int day = int.parse(parts[0]);
        if (day >= 1 && day <= 31) {
          return DateTime(now.year, now.month, day);
        }
      } else if (parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        // Day and month entered (e.g., "23/06")
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
          return DateTime(now.year, month, day);
        }
      } else if (parts.length == 3 && parts[0].isNotEmpty && parts[1].isNotEmpty && parts[2].isNotEmpty) {
        // Complete date entered (e.g., "23/06/2000")
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);

        // Handle 2-digit years
        if (year < 100) {
          year += (year < 50) ? 2000 : 1900;
        }

        if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
          return DateTime(year, month, day);
        }
      }

      // Try parsing with the full format
      return DateFormat("dd/MM/yyyy").parseStrict(input);
    } catch (e) {
      return null;
    }
  }

  /// Checks whether the overlay should be displayed above or below the anchor
  /// based on available screen space.
  void checkRenderObjects() {
    if (key1.currentContext != null && key2.currentContext != null) {
      final RenderBox? render1 =
      key1.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? render2 =
      key2.currentContext?.findRenderObject() as RenderBox?;

      if (render1 != null && render2 != null) {
        final screenHeight = MediaQuery.of(context).size.height;
        double y = render1.localToGlobal(Offset.zero).dy;

        if (Platform.isAndroid || Platform.isIOS) {
          if (screenHeight - y - (MediaQuery.of(context).size.height * 0.4) <
              render2.size.height) {
            displayOverlayBottom = false;
          }
        } else {
          if (screenHeight - y < render2.size.height) {
            displayOverlayBottom = false;
          }
        }

        setState(() {}); // Update the state after calculation.
      }
    }
  }


  Offset setOffset() {
    return Offset(widget.dropdownOffset?.dx ?? 05,
        displayOverlayBottom ? widget.dropdownOffset?.dy ?? 55 : -10);
  }

  Widget _buildHeader() {
    return Container(
      alignment: widget.pickerDecoration?.headerDecoration?.alignment,
      margin: widget.pickerDecoration?.headerDecoration?.headerMargin ?? EdgeInsets.zero,
      padding: widget.pickerDecoration?.headerDecoration?.headerPadding ?? EdgeInsets.all(10),
      decoration:  widget.pickerDecoration?.headerDecoration?.headerDecoration ??BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            focusNode: arrowLeftFocusNode,
            focusColor: widget.pickerDecoration?.headerDecoration?.iconDecoration?.focusColor ?? Colors.white,
            hoverColor: widget.pickerDecoration?.headerDecoration?.iconDecoration?.hoverColor ?? Colors.white12,
            icon: Icon(
              widget.pickerDecoration?.headerDecoration?.iconDecoration?.leftIcon ?? Icons.chevron_left,
              size: widget.pickerDecoration?.headerDecoration?.iconDecoration?.leftIconSize,
              color: arrowLeftFocusNode.hasFocus
                  ? widget.pickerDecoration?.headerDecoration?.iconDecoration?.leftFocusIconColor ?? Colors.black
                  : widget.pickerDecoration?.headerDecoration?.iconDecoration?.leftIconColor ?? Colors.white,
            ),
            onPressed: _canNavigateToPreviousMonth() ? _previousMonth : null,
          ),
          Spacer(),

          Material(
            color: Colors.transparent,
            child: InkWell(
              focusNode: monthYearFocusNode,
              focusColor: widget.pickerDecoration?.headerDecoration?.iconDecoration?.focusColor ?? Colors.white,
              hoverColor: widget.pickerDecoration?.headerDecoration?.iconDecoration?.hoverColor ?? Colors.white12,
              borderRadius: BorderRadius.circular(05),
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

          IconButton(
            focusNode: arrowRightFocusNode,
            focusColor: widget.pickerDecoration?.headerDecoration?.iconDecoration?.focusColor ?? Colors.white,
            hoverColor: widget.pickerDecoration?.headerDecoration?.iconDecoration?.hoverColor ?? Colors.white12,
            icon: Icon(
              widget.pickerDecoration?.headerDecoration?.iconDecoration?.rightIcon ?? Icons.chevron_right,
              size: widget.pickerDecoration?.headerDecoration?.iconDecoration?.rightIconSize,
              color: arrowRightFocusNode.hasFocus
                  ? widget.pickerDecoration?.headerDecoration?.iconDecoration?.rightFocusIconColor ?? Colors.black
                  : widget.pickerDecoration?.headerDecoration?.iconDecoration?.rightIconColor ?? Colors.white,
            ),
            onPressed: _canNavigateToNextMonth() ? _nextMonth : null,
          )
        ],
      ),
    );
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

  bool _canNavigateToPreviousMonth() {
    if (widget.firstDate == null) return true;
    DateTime firstOfMonth = DateTime(_currentDisplayDate.year, _currentDisplayDate.month, 1);
    DateTime firstOfPreviousMonth = DateTime(firstOfMonth.year, firstOfMonth.month - 1, 1);
    return !firstOfPreviousMonth.isBefore(DateTime(widget.firstDate!.year, widget.firstDate!.month, 1));
  }

  void _previousMonth() {
    if (_canNavigateToPreviousMonth()) {
      setState(() {
        focusSelectedDate = DateTime(_currentDisplayDate.year, _currentDisplayDate.month - 1, 1);
        _currentDisplayDate = DateTime(_currentDisplayDate.year, _currentDisplayDate.month - 1, 1);
      });
    }
  }

  bool _canNavigateToNextMonth() {
    if (widget.lastDate == null) return true;
    DateTime firstOfMonth = DateTime(_currentDisplayDate.year, _currentDisplayDate.month, 1);
    DateTime firstOfNextMonth = DateTime(firstOfMonth.year, firstOfMonth.month + 1, 1);
    return !firstOfNextMonth.isAfter(DateTime(widget.lastDate!.year, widget.lastDate!.month, 1));
  }

  void _nextMonth() {
    if (_canNavigateToNextMonth()) {
      setState(() {
        focusSelectedDate = DateTime(_currentDisplayDate.year, _currentDisplayDate.month + 1, 1);
        _currentDisplayDate = DateTime(_currentDisplayDate.year, _currentDisplayDate.month + 1, 1);
      });
    }
  }

  List<DateTime> getCalendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // Start from the previous Monday (or same day if already Monday)
    final startOffset = firstDayOfMonth.weekday % 7; // Monday = 1, Sunday = 7
    final startDate = firstDayOfMonth.subtract(Duration(days: startOffset));

    // End on Sunday (or same day if already Sunday)
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

  List<DateTime> _generateCalendarDays() {
    // Get the first day of the currently displayed month
    final firstDayOfMonth = DateTime(
      _currentDisplayDate.year, _currentDisplayDate.month, 1, 0, 0, 0,
    ); // Set time to midnight

    // Calculate the number of days to show from the previous month
    int daysBefore = firstDayOfMonth.weekday % 7;

    // Generate 42 days (6 weeks) for the calendar grid
    return List.generate(42, (index) {
      final date = firstDayOfMonth.subtract(Duration(days: daysBefore)).add(Duration(days: index));
      return DateTime(
        date.year, date.month, date.day, date.hour, 0, 0,
      ); // Ensure time is set to midnight
    });
  }


  /// Moves focus to an adjacent month in the calendar grid.
  void moveFocusToAdjacentMonth(int direction, int currentIndex,prevMonth) {
    setState(() {
      _currentDisplayDate = prevMonth;
    });

    // Delay selection of the correct target date until calendar rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newMonthDays = _generateCalendarDays();
      int weekdayColumn = currentIndex % 7;
      final monthDates = newMonthDays.where((date) => date.month == _currentDisplayDate.month).toList();

      DateTime selectedDate = direction < 0 ? monthDates.lastWhere((date) => date.weekday % 7 == weekdayColumn, orElse: () => monthDates.last,)
          : monthDates.firstWhere((date) => date.weekday % 7 == weekdayColumn, orElse: () => monthDates.first);

      setState(() {
        _currentDisplayDate = selectedDate;
        focusSelectedDate = selectedDate;
      });
    });
  }

  void moveFocusLeftRightAdjacentMonth(int direction, int currentIndex, DateTime targetMonth) {
    setState(() {
      _currentDisplayDate = targetMonth;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DateTime selectedDate;

      if (direction < 0) {
        // Left: move to last day of previous month
        selectedDate = DateTime(targetMonth.year, targetMonth.month + 1, 0); // Last day of previous month
      } else {
        // Right: move to first day of next month
        selectedDate = DateTime(targetMonth.year, targetMonth.month, 1);
      }

      setState(() {
        _currentDisplayDate = DateTime(selectedDate.year, selectedDate.month);
        focusSelectedDate = selectedDate;
      });
    });
  }


  Widget _buildCalendar() {
    final calendarDays = _generateCalendarDates();

    // Align focusSelectedDate to displayedMonth
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
        LogicalKeySet(LogicalKeyboardKey.tab): () => handleTab(),
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab): () => handleTab(reverse: true),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): () {
          dateFocusNode.requestFocus();
          if (dateFocusNode.hasFocus && currentIndex > 0) {
            final prevDate = calendarDays[currentIndex - 1];

            if (!prevDate.isBefore(widget.firstDate ?? DateTime(1900))) {
              setState(() {
                focusSelectedDate = prevDate;
                if (prevDate.month != _currentDisplayDate.month) {
                  _currentDisplayDate = DateTime(prevDate.year, prevDate.month);
                }
              });
            }
          }else{
            final prevMonth = DateTime(
              _currentDisplayDate.year,
              _currentDisplayDate.month - 1,
              1,
            );
            if (!prevMonth.isBefore(
              DateTime(widget.firstDate?.year??1900, widget.firstDate?.month??01, 1),
            )) {
              moveFocusLeftRightAdjacentMonth(-1, currentIndex,prevMonth);
            }
          }
        },
        LogicalKeySet(LogicalKeyboardKey.arrowRight): () {
          dateFocusNode.requestFocus();
          if (dateFocusNode.hasFocus && currentIndex < calendarDays.length - 1) {
            final nextDate = calendarDays[currentIndex + 1];
            if (!nextDate.isAfter(widget.lastDate ?? DateTime(2100))) {
              setState(() {
                focusSelectedDate = nextDate;
                if (nextDate.month != _currentDisplayDate.month) {
                  _currentDisplayDate = DateTime(nextDate.year, nextDate.month);
                }
              });
            }
          }else{
            final prevMonth = DateTime(
              _currentDisplayDate.year,
              _currentDisplayDate.month + 1,
              1,
            );
            if (!prevMonth.isBefore(
              DateTime(widget.firstDate?.year??1900, widget.firstDate?.month??01, 1),
            )) {
              moveFocusLeftRightAdjacentMonth(1, currentIndex,prevMonth);
            }
          }
        },
        LogicalKeySet(LogicalKeyboardKey.arrowUp): () {
          dateFocusNode.requestFocus();

          if (dateFocusNode.hasFocus) {
            int targetIndex = currentIndex - 7;

            if (targetIndex >= 0) {
              final targetDate = calendarDays[targetIndex];

              // Only update if within range
              if (!targetDate.isBefore(widget.firstDate ?? DateTime(1900))) {
                setState(() {
                  focusSelectedDate = targetDate;

                  // Switch to new month if needed
                  if (targetDate.month != _currentDisplayDate.month ||
                      targetDate.year != _currentDisplayDate.year) {
                    _currentDisplayDate = DateTime(targetDate.year, targetDate.month);
                  }
                });
              }
            }else {
              // Move to the previous month if necessary
              final prevMonth = DateTime(
                _currentDisplayDate.year,
                _currentDisplayDate.month - 1,
                1,
              );
              if (!prevMonth.isBefore(
                DateTime(widget.firstDate?.year??1900, widget.firstDate?.month??01, 1),
              )) {
                moveFocusToAdjacentMonth(-1, currentIndex,prevMonth);
              }
            }

          }
        },
        LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
          dateFocusNode.requestFocus();
          if (dateFocusNode.hasFocus && currentIndex + 7 < calendarDays.length) {

            final targetDate = calendarDays[currentIndex + 7];
            if (!targetDate.isAfter(widget.lastDate ?? DateTime(2100))) {
              setState(() {
                focusSelectedDate = targetDate;
                if (targetDate.month != _currentDisplayDate.month) {
                  _currentDisplayDate = DateTime(targetDate.year, targetDate.month);
                }
              });
            }
          }else {
            // Move to the next month if necessary
            final nextMonth = DateTime(
              _currentDisplayDate.year,
              _currentDisplayDate.month + 1,
              1,
            );
            final lastAllowedDate = DateTime(widget.lastDate?.year??2100, 12, 31);
            print(lastAllowedDate);
            if (!nextMonth.isAfter(lastAllowedDate)) {
              // print("!nextMonth");
              moveFocusToAdjacentMonth(1, currentIndex,nextMonth);
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

                final isSelected =
                    date.year == selectedDate.year &&
                        date.month == selectedDate.month &&
                        date.day == selectedDate.day;
                final isFocusDate =
                    date.year == focusSelectedDate.year &&
                        date.month == focusSelectedDate.month &&
                        date.day == focusSelectedDate.day;

                return Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                  ),
                  child: Focus(
                    focusNode: dateFocusNode,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          focusSelectedDate = date;
                        });
                        _selectDate(date);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: dayDecoration(isCurrentMonth,isFocusDate,isSelected),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: dayTextStyle(isCurrentMonth,isFocusDate,isSelected),
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

  BoxDecoration dayDecoration(isCurrentMonth,isFocusDate,isSelected){
    if(isCurrentMonth && isSelected){
      return widget.pickerDecoration?.dayDecoration?.selectedDecoration ?? BoxDecoration(
        color:Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(6),
      );
    }
    if(isCurrentMonth == false && isSelected == false){
      widget.pickerDecoration?.dayDecoration?.unSelectedDecoration ?? BoxDecoration(
        color:Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      );
    }

    if(isFocusDate){
      return widget.pickerDecoration?.dayDecoration?.focusDecoration ?? BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).primaryColor),
      );
    }

    return BoxDecoration();
  }

  TextStyle dayTextStyle(isCurrentMonth,isFocusDate,isSelected){
    if(isCurrentMonth){

      if(isSelected){
        return widget.pickerDecoration?.dayDecoration?.selectedTextStyle ?? TextStyle(
          color:  Colors.white,
          fontWeight:  FontWeight.bold,
        );
      }else if(isFocusDate){
        return widget.pickerDecoration?.dayDecoration?.focusTextStyle ?? TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.normal,
        );
      }else{
        return widget.pickerDecoration?.dayDecoration?.unSelectedTextStyle ?? TextStyle(
          color:  Colors.black,
          fontWeight:  FontWeight.normal,
        );
      }
    }else{
      return widget.pickerDecoration?.dayDecoration?.disableTextStyle ?? TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.normal,
      );
    }
  }

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
                style: widget.pickerDecoration?.weekTextStyle ?? TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<DateTime> _generateCalendarDates() {
    DateTime firstDayOfMonth = DateTime(focusSelectedDate.year, focusSelectedDate.month, 1);
    DateTime lastDayOfMonth = DateTime(focusSelectedDate.year, focusSelectedDate.month + 1, 0);
    int daysInMonth = lastDayOfMonth.day;
    int firstWeekday = firstDayOfMonth.weekday % 7;

    List<DateTime> calendarDates = [];

    // Fill leading empty slots with previous month dates
    for (int i = firstWeekday - 1; i >= 0; i--) {
      calendarDates.add(firstDayOfMonth.subtract(Duration(days: i + 1)));
    }

    // Fill current month dates
    for (int day = 1; day <= daysInMonth; day++) {
      calendarDates.add(DateTime(focusSelectedDate.year, focusSelectedDate.month, day));
    }

    // Fill trailing empty slots to complete the last week (total must be multiple of 7)
    while (calendarDates.length % 7 != 0) {
      calendarDates.add(calendarDates.last.add(const Duration(days: 1)));
    }

    return calendarDates;
  }

  bool _isValidDate(DateTime date) {
    if (widget.firstDate != null && date.isBefore(widget.firstDate!)) {
      return false;
    }
    if (widget.lastDate != null && date.isAfter(widget.lastDate!)) {
      return false;
    }
    return true;
  }

  void _selectDate(DateTime date) {
    setState(() {
      widget.textController.text = DateFormat("dd/MM/yyyy").format(date);
    });

    widget.onDateSelected.call(date);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      link: widget.layerLink,
      offset: setOffset(),
      followerAnchor: displayOverlayBottom ? Alignment.topLeft : Alignment.bottomLeft,
      child: LayoutBuilder(
          builder: (context, c) {
            return Container(
              key: key1,
              height: widget.pickerDecoration?.height ?? 330,

              decoration: widget.pickerDecoration?.menuDecoration ?? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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

                    if(canShowDate)
                      _buildHeader(),

                    if(canShowDate)
                      Expanded(child: _buildCalendar()),

                    if(canShowMonth && !canShowYear)
                      Expanded(
                        child: MyMonthPicker(
                            lastDate: widget.lastDate,
                            firstDate: widget.firstDate,
                            initialDate: _currentDisplayDate,
                            pickerDecoration: widget.pickerDecoration,
                            width: widget.pickerDecoration?.width ?? 270,
                            height: widget.pickerDecoration?.height ?? 320,
                            currentDisplayDate: _currentDisplayDate,
                            changeToYearPicker:() {
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
                            }
                        ),
                      ),

                    if(canShowYear)
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
                      )
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged); // Remove listener
    dateFocusNode.dispose();
    monthYearFocusNode.dispose();
    arrowRightFocusNode.dispose();
    arrowLeftFocusNode.dispose();
    super.dispose();
  }
}