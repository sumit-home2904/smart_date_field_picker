import 'package:flutter/material.dart';

/// Defines styling and behavior configuration for the overall date picker UI.
class PickerDecoration {
  /// Whether the cursor should be visible.
  final bool? showCursor;

  /// Color when a cell or field is hovered.
  final Color? hoverColor;

  /// Color when a cell or field is focused.
  final Color? focusColor;

  /// Color of the cursor in text input.
  final Color? cursorColor;

  /// Width of the cursor in text input.
  final double? cursorWidth;

  /// Radius of the cursor (rounded edges).
  final Radius? cursorRadius;

  /// The general text style applied to input or cells.
  final TextStyle? textStyle;

  /// Fixed height for the input or picker area.
  final double? height, width;

  /// Custom height of the cursor.
  final double? cursorHeight;

  /// Text alignment within input fields.
  final TextAlign? textAlign;

  /// Cursor color when there's an error.
  final Color? cursorErrorColor;

  /// Text style for week names (Mon, Tue, etc.).
  final TextStyle? weekTextStyle;

  /// Decoration for dropdowns or overlays.
  final Decoration? menuDecoration;

  /// Styling configuration for individual day cells.
  final DayDecoration? dayDecoration;

  /// Styling configuration for month/year cells.
  final MonthDecoration? monthDecoration;

  /// Enables or disables selection features like long press copy/paste.
  final bool? enableInteractiveSelection;

  /// Styling configuration for the header section.
  final HeaderDecoration? headerDecoration;

  final YearDecoration? yearDecoration;
  const PickerDecoration({
    this.width,
    this.height,
    this.textStyle,
    this.textAlign,
    this.showCursor,
    this.hoverColor,
    this.focusColor,
    this.cursorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.dayDecoration,
    this.weekTextStyle,
    this.menuDecoration,
    this.monthDecoration,
    this.cursorErrorColor,
    this.headerDecoration,
    this.yearDecoration,
    this.enableInteractiveSelection,
  });

  /// Creates a copy of this decoration with overridden fields.
  PickerDecoration copyWith({
    bool? showCursor,
    Color? hoverColor,
    Color? focusColor,
    Color? cursorColor,
    TextAlign? textAlign,
    TextStyle? textStyle,
    double? cursorWidth,
    double? height,
    width,
    Radius? cursorRadius,
    double? cursorHeight,
    Color? cursorErrorColor,
    TextStyle? weekTextStyle,
    Decoration? menuDecoration,
    DayDecoration? dayDecoration,
    YearDecoration? yearDecoration,
    MonthDecoration? monthDecoration,
    bool? enableInteractiveSelection,
    HeaderDecoration? headerDecoration,
  }) {
    return PickerDecoration(
      width: width ?? this.width,
      height: height ?? this.height,
      textStyle: textStyle ?? this.textStyle,
      textAlign: textAlign ?? this.textAlign,
      showCursor: showCursor ?? this.showCursor,
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      dayDecoration: dayDecoration ?? this.dayDecoration,
      weekTextStyle: weekTextStyle ?? this.weekTextStyle,
      yearDecoration: yearDecoration ?? this.yearDecoration,
      menuDecoration: menuDecoration ?? this.menuDecoration,
      monthDecoration: monthDecoration ?? this.monthDecoration,
      cursorErrorColor: cursorErrorColor ?? this.cursorErrorColor,
      headerDecoration: headerDecoration ?? this.headerDecoration,
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
    );
  }
}

/// Defines styling for the header area of the picker.
class HeaderDecoration {
  /// Text style for the header (default state).
  final TextStyle? headerTextStyle;

  /// Text style when the header is focused.
  final TextStyle? focusTextStyle;

  /// Alignment of the header content.
  final AlignmentGeometry? alignment;

  /// Optional styling for navigation icons (left/right).
  final IconDecoration? iconDecoration;

  /// Box decoration (e.g., background color, border) for the header container.
  final BoxDecoration? headerDecoration;

  /// Padding inside the header.
  final EdgeInsetsGeometry? headerPadding;

  /// Margin outside the header container.
  final EdgeInsetsGeometry? headerMargin;

  const HeaderDecoration({
    this.alignment,
    this.headerMargin,
    this.headerPadding,
    this.iconDecoration,
    this.headerTextStyle,
    this.focusTextStyle,
    this.headerDecoration,
  });

  HeaderDecoration copyWith({
    TextStyle? focusTextStyle,
    TextStyle? headerTextStyle,
    AlignmentGeometry? alignment,
    IconDecoration? iconDecoration,
    BoxDecoration? headerDecoration,
    EdgeInsetsGeometry? headerMargin,
    EdgeInsetsGeometry? headerPadding,
  }) {
    return HeaderDecoration(
      alignment: alignment ?? this.alignment,
      headerMargin: headerMargin ?? this.headerMargin,
      headerPadding: headerPadding ?? this.headerPadding,
      iconDecoration: iconDecoration ?? this.iconDecoration,
      focusTextStyle: focusTextStyle ?? this.focusTextStyle,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      headerDecoration: headerDecoration ?? this.headerDecoration,
    );
  }
}

/// Defines configuration for navigation or decorative icons in the picker.
class IconDecoration {
  /// Icon for left navigation (e.g., previous month/year).
  final IconData? leftIcon;

  /// Icon for right navigation (e.g., next month/year).
  final IconData? rightIcon;

  /// Icon color on hover.
  final Color? hoverColor;

  /// Icon color on focus.
  final Color? focusColor;

  /// Icon color in default state (left icon).
  final Color? leftIconColor;

  /// Icon size (left).
  final double? leftIconSize;

  /// Icon color in default state (right icon).
  final Color? rightIconColor;

  /// Icon size (right).
  final double? rightIconSize;

  /// Icon color when left icon is focused.
  final Color? leftFocusIconColor;

  /// Icon color when right icon is focused.
  final Color? rightFocusIconColor;

  const IconDecoration({
    this.leftIcon,
    this.rightIcon,
    this.hoverColor,
    this.focusColor,
    this.leftIconSize,
    this.leftIconColor,
    this.rightIconSize,
    this.rightIconColor,
    this.leftFocusIconColor,
    this.rightFocusIconColor,
  });

  IconDecoration copyWith({
    Color? hoverColor,
    Color? focusColor,
    IconData? leftIcon,
    IconData? rightIcon,
    double? leftIconSize,
    Color? leftIconColor,
    Color? rightIconColor,
    double? rightIconSize,
    Color? leftFocusIconColor,
    Color? rightFocusIconColor,
  }) {
    return IconDecoration(
      leftIcon: leftIcon ?? this.leftIcon,
      rightIcon: rightIcon ?? this.rightIcon,
      focusColor: focusColor ?? this.focusColor,
      hoverColor: hoverColor ?? this.hoverColor,
      leftIconSize: leftIconSize ?? this.leftIconSize,
      leftIconColor: leftIconColor ?? this.leftIconColor,
      rightIconSize: rightIconSize ?? this.rightIconSize,
      rightIconColor: rightIconColor ?? this.rightIconColor,
      leftFocusIconColor: leftFocusIconColor ?? this.leftFocusIconColor,
      rightFocusIconColor: rightFocusIconColor ?? this.rightFocusIconColor,
    );
  }
}

/// Defines styling for month tiles in the picker.
class MonthDecoration {
  /// Hover color for the cell.
  final Color? hoverColor;

  /// Focus color for the cell.
  final Color? focusColor;

  /// Text style when the cell is selected.
  final TextStyle? selectedTextStyle;

  /// Text style when the cell is not selected.
  final TextStyle? unSelectedTextStyle;

  /// Text style when the cell is disabled.
  final TextStyle? disableTextStyle;

  /// Box decoration when the cell is selected.
  final BoxDecoration? selectedDecoration;

  /// Box decoration when the cell is focused.
  final BoxDecoration? focusDecoration;

  /// Box decoration when the cell is not selected.
  final BoxDecoration? unSelectedDecoration;

  const MonthDecoration({
    this.hoverColor,
    this.focusColor,
    this.disableTextStyle,
    this.focusDecoration,
    this.selectedTextStyle,
    this.selectedDecoration,
    this.unSelectedTextStyle,
    this.unSelectedDecoration,
  });

  MonthDecoration copyWith({
    double? height,
    double? width,
    Color? hoverColor,
    Color? focusColor,
    TextStyle? disableTextStyle,
    TextStyle? selectedTextStyle,
    BoxDecoration? focusDecoration,
    TextStyle? unSelectedTextStyle,
    BoxDecoration? selectedDecoration,
    BoxDecoration? unSelectedDecoration,
  }) {
    return MonthDecoration(
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
      focusDecoration: focusDecoration ?? this.focusDecoration,
      disableTextStyle: disableTextStyle ?? this.disableTextStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      selectedDecoration: selectedDecoration ?? this.selectedDecoration,
      unSelectedTextStyle: unSelectedTextStyle ?? this.unSelectedTextStyle,
      unSelectedDecoration: unSelectedDecoration ?? this.unSelectedDecoration,
    );
  }
}


/// Defines styling for year tiles in the picker.
class YearDecoration {
  /// Hover color for the cell.
  final Color? hoverColor;

  /// Focus color for the cell.
  final Color? focusColor;

  /// Text style when the cell is selected.
  final TextStyle? selectedTextStyle;

  /// Text style when the cell is not selected.
  final TextStyle? unSelectedTextStyle;

  /// Text style when the cell is disabled.
  final TextStyle? disableTextStyle;

  /// Box decoration when the cell is selected.
  final BoxDecoration? selectedDecoration;

  /// Box decoration when the cell is focused.
  final BoxDecoration? focusDecoration;

  /// Box decoration when the cell is not selected.
  final BoxDecoration? unSelectedDecoration;

  const YearDecoration({
    this.hoverColor,
    this.focusColor,
    this.disableTextStyle,
    this.focusDecoration,
    this.selectedTextStyle,
    this.selectedDecoration,
    this.unSelectedTextStyle,
    this.unSelectedDecoration,
  });

  YearDecoration copyWith({
    double? height,
    double? width,
    Color? hoverColor,
    Color? focusColor,
    TextStyle? disableTextStyle,
    TextStyle? selectedTextStyle,
    BoxDecoration? focusDecoration,
    TextStyle? unSelectedTextStyle,
    BoxDecoration? selectedDecoration,
    BoxDecoration? unSelectedDecoration,
  }) {
    return YearDecoration(
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
      focusDecoration: focusDecoration ?? this.focusDecoration,
      disableTextStyle: disableTextStyle ?? this.disableTextStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      selectedDecoration: selectedDecoration ?? this.selectedDecoration,
      unSelectedTextStyle: unSelectedTextStyle ?? this.unSelectedTextStyle,
      unSelectedDecoration: unSelectedDecoration ?? this.unSelectedDecoration,
    );
  }
}


/// Defines styling for individual day tiles in the picker calendar.
class DayDecoration {
  /// Hover color for the cell.
  final Color? hoverColor;

  /// Text style for disabled (non-interactive) days.
  final TextStyle? disableTextStyle;

  /// Text style when the day is focused.
  final TextStyle? focusTextStyle;

  /// Text style for selected day.
  final TextStyle? selectedTextStyle;

  /// Text style for unselected day.
  final TextStyle? unSelectedTextStyle;

  /// Decoration for a focused day.
  final BoxDecoration? focusDecoration;

  /// Decoration for a selected day.
  final BoxDecoration? selectedDecoration;

  /// Decoration for an unselected day.
  final BoxDecoration? unSelectedDecoration;

  const DayDecoration({
    this.hoverColor,
    this.focusTextStyle,
    this.focusDecoration,
    this.disableTextStyle,
    this.selectedTextStyle,
    this.selectedDecoration,
    this.unSelectedTextStyle,
    this.unSelectedDecoration,
  });

  DayDecoration copyWith({
    double? height,
    double? width,
    Color? hoverColor,
    Color? focusColor,
    TextStyle? focusTextStyle,
    TextStyle? disableTextStyle,
    TextStyle? selectedTextStyle,
    TextStyle? unSelectedTextStyle,
    BoxDecoration? focusDecoration,
    BoxDecoration? selectedDecoration,
    BoxDecoration? unSelectedDecoration,
  }) {
    return DayDecoration(
      hoverColor: hoverColor ?? this.hoverColor,
      focusTextStyle: focusTextStyle ?? this.focusTextStyle,
      focusDecoration: focusDecoration ?? this.focusDecoration,
      disableTextStyle: disableTextStyle ?? this.disableTextStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      selectedDecoration: selectedDecoration ?? this.selectedDecoration,
      unSelectedTextStyle: unSelectedTextStyle ?? this.unSelectedTextStyle,
      unSelectedDecoration: unSelectedDecoration ?? this.unSelectedDecoration,
    );
  }
}
