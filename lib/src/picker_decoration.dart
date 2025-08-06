import 'package:flutter/material.dart';

/// Defines overall configuration for the date picker UI.
///
/// Now delegates all styling (text and decoration) to [PickerTheme].
class PickerDecoration {
  /// Whether the cursor should be visible.
  final bool? showCursor;

  /// Color of the cursor in text input.
  final Color? cursorColor;

  /// Width of the cursor in text input.
  final double? cursorWidth;

  /// Radius of the cursor for rounded edges.
  final Radius? cursorRadius;

  /// General text style for input fields (not cells).
  final TextStyle? textStyle;

  /// Fixed height and width of the picker area.
  final double? height, width;

  /// Custom height of the cursor.
  final double? cursorHeight;

  /// Alignment for text in input fields.
  final TextAlign? textAlign;

  /// Cursor color when there's an error.
  final Color? cursorErrorColor;

  /// Text style for week names (Mon, Tue, etc.).
  final TextStyle? weekTextStyle;

  /// Decoration for dropdowns or overlays.
  final Decoration? menuDecoration;

  /// Enables or disables text selection features (long press, copy/paste).
  final bool? enableInteractiveSelection;

  /// Styling configuration for the header section.
  final HeaderTheme? headerTheme;

  /// Unified styling for cells (day, month, year).
  final PickerTheme? pickerTheme;

  const PickerDecoration({
    this.width,
    this.height,
    this.textStyle,
    this.textAlign,
    this.showCursor,
    this.cursorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.weekTextStyle,
    this.menuDecoration,
    this.cursorErrorColor,
    this.headerTheme,
    this.enableInteractiveSelection,
    this.pickerTheme,
  });

  /// Creates a copy of this decoration with overridden fields.
  PickerDecoration copyWith({
    bool? showCursor,
    Color? cursorColor,
    TextAlign? textAlign,
    TextStyle? textStyle,
    double? cursorWidth,
    double? height,
    double? width,
    Radius? cursorRadius,
    double? cursorHeight,
    Color? cursorErrorColor,
    TextStyle? weekTextStyle,
    Decoration? menuDecoration,
    bool? enableInteractiveSelection,
    HeaderTheme? headerTheme,
    PickerTheme? pickerTheme,
  }) {
    return PickerDecoration(
      width: width ?? this.width,
      height: height ?? this.height,
      textStyle: textStyle ?? this.textStyle,
      textAlign: textAlign ?? this.textAlign,
      showCursor: showCursor ?? this.showCursor,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      weekTextStyle: weekTextStyle ?? this.weekTextStyle,
      menuDecoration: menuDecoration ?? this.menuDecoration,
      cursorErrorColor: cursorErrorColor ?? this.cursorErrorColor,
      headerTheme: headerTheme ?? this.headerTheme,
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
      pickerTheme: pickerTheme ?? this.pickerTheme,
    );
  }
}

/// Defines styling for the header area of the picker.
class HeaderTheme {
  final TextStyle? headerTextStyle;
  final TextStyle? focusTextStyle;
  final AlignmentGeometry? alignment;
  final IconDecoration? iconDecoration;
  final BoxDecoration? boxDecoration;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? headerMargin;

  const HeaderTheme({
    this.alignment,
    this.headerMargin,
    this.headerPadding,
    this.iconDecoration,
    this.headerTextStyle,
    this.focusTextStyle,
    this.boxDecoration,
  });

  HeaderTheme copyWith({
    TextStyle? focusTextStyle,
    TextStyle? headerTextStyle,
    AlignmentGeometry? alignment,
    IconDecoration? iconDecoration,
    BoxDecoration? boxDecoration,
    EdgeInsetsGeometry? headerMargin,
    EdgeInsetsGeometry? headerPadding,
  }) {
    return HeaderTheme(
      alignment: alignment ?? this.alignment,
      headerMargin: headerMargin ?? this.headerMargin,
      headerPadding: headerPadding ?? this.headerPadding,
      iconDecoration: iconDecoration ?? this.iconDecoration,
      focusTextStyle: focusTextStyle ?? this.focusTextStyle,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      boxDecoration: boxDecoration ?? this.boxDecoration,
    );
  }
}

/// Defines configuration for navigation or decorative icons in the picker.
class IconDecoration {
  final IconData? leftIcon;
  final IconData? rightIcon;
  final Color? leftIconColor;
  final double? leftIconSize;
  final Color? rightIconColor;
  final double? rightIconSize;
  final Color? leftFocusIconColor;
  final Color? rightFocusIconColor;

  const IconDecoration({
    this.leftIcon,
    this.rightIcon,
    this.leftIconSize,
    this.leftIconColor,
    this.rightIconSize,
    this.rightIconColor,
    this.leftFocusIconColor,
    this.rightFocusIconColor,
  });

  IconDecoration copyWith({
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
      leftIconSize: leftIconSize ?? this.leftIconSize,
      leftIconColor: leftIconColor ?? this.leftIconColor,
      rightIconSize: rightIconSize ?? this.rightIconSize,
      rightIconColor: rightIconColor ?? this.rightIconColor,
      leftFocusIconColor: leftFocusIconColor ?? this.leftFocusIconColor,
      rightFocusIconColor: rightFocusIconColor ?? this.rightFocusIconColor,
    );
  }
}

/// A guide class that defines all available text styles and decorations
/// for customizing the date picker (day, month, and year views).
///
/// Use this to provide consistent styling across focus, selection,
/// and hover states.
class PickerTheme {
  /// Style for disabled cells (e.g., days outside allowed range).
  final TextStyle? disableTextStyle;

  /// Style for the focused cell (e.g., hovered or keyboard-focused item).
  final TextStyle? focusTextStyle;

  /// Style for the selected cell (chosen day, month, or year).
  final TextStyle? selectedTextStyle;

  /// Style for unselected but enabled cells (default text style).
  final TextStyle? unSelectedTextStyle;

  /// Decoration for the focused cell (border, background, etc.).
  final BoxDecoration? focusDecoration;

  /// Decoration for the selected cell (border, background, etc.).
  final BoxDecoration? selectedDecoration;

  /// Decoration for unselected but enabled cells.
  final BoxDecoration? unSelectedDecoration;

  /// Hover effect radius for cells.
  final double? hoverRadius;

  /// Background color when a cell is hovered.
  final Color? hoverColor;

  /// Background color when a cell is focused.
  final Color? focusColor;

  const PickerTheme({
    this.disableTextStyle,
    this.focusTextStyle,
    this.selectedTextStyle,
    this.unSelectedTextStyle,
    this.focusDecoration,
    this.selectedDecoration,
    this.unSelectedDecoration,
    this.hoverRadius,
    this.hoverColor,
    this.focusColor,
  });

  /// Creates a new [PickerTheme] by overriding selected fields.
  PickerTheme copyWith({
    TextStyle? disableTextStyle,
    TextStyle? focusTextStyle,
    TextStyle? selectedTextStyle,
    TextStyle? unSelectedTextStyle,
    BoxDecoration? focusDecoration,
    BoxDecoration? selectedDecoration,
    BoxDecoration? unSelectedDecoration,
    double? hoverRadius,
    Color? hoverColor,
    Color? focusColor,
  }) {
    return PickerTheme(
      disableTextStyle: disableTextStyle ?? this.disableTextStyle,
      focusTextStyle: focusTextStyle ?? this.focusTextStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      unSelectedTextStyle: unSelectedTextStyle ?? this.unSelectedTextStyle,
      focusDecoration: focusDecoration ?? this.focusDecoration,
      selectedDecoration: selectedDecoration ?? this.selectedDecoration,
      unSelectedDecoration: unSelectedDecoration ?? this.unSelectedDecoration,
      hoverRadius: hoverRadius ?? this.hoverRadius,
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
    );
  }
}
