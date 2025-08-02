import 'package:flutter/material.dart';


class PickerDecoration {
  final bool? showCursor;
  final Color? hoverColor;
  final Color? focusColor;
  final Color? cursorColor;
  final double? cursorWidth;
  final Radius? cursorRadius;
  final TextStyle? textStyle;
  final double? height,width;
  final double? cursorHeight;
  final TextAlign? textAlign;
  final Color? cursorErrorColor;
  final TextStyle? weekTextStyle;
  final Decoration? menuDecoration;
  final DayDecoration? dayDecoration;
  final MonthDecoration? monthDecoration;
  final bool? enableInteractiveSelection;
  final HeaderDecoration? headerDecoration;

  PickerDecoration({
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
    this.enableInteractiveSelection,
  });

  PickerDecoration copyWith({
    bool? showCursor,
    Color? hoverColor,
    Color? focusColor,
    Color? cursorColor,
    TextAlign? textAlign,
    TextStyle? textStyle,
    double ? cursorWidth,
    double? height,width,
    Radius? cursorRadius,
    double ? cursorHeight,
    Color? cursorErrorColor,
    TextStyle? weekTextStyle,
    Decoration? menuDecoration,
    DayDecoration? dayDecoration,
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
      menuDecoration: menuDecoration ?? this.menuDecoration,
      monthDecoration: monthDecoration ?? this.monthDecoration,
      cursorErrorColor: cursorErrorColor ?? this.cursorErrorColor,
      headerDecoration: headerDecoration ?? this.headerDecoration,
      enableInteractiveSelection: enableInteractiveSelection ?? this.enableInteractiveSelection,
    );
  }

}

class HeaderDecoration{
  final TextStyle? headerTextStyle;
  final TextStyle? focusTextStyle;
  final AlignmentGeometry? alignment;
  final IconDecoration? iconDecoration;
  final BoxDecoration? headerDecoration;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? headerMargin;

  HeaderDecoration({
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
  }){

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

class IconDecoration{
  final Color? hoverColor;
  final Color? focusColor;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final Color? leftIconColor;
  final double? leftIconSize;
  final Color? rightIconColor;
  final double? rightIconSize;
  final Color? leftFocusIconColor;
  final Color? rightFocusIconColor;


  IconDecoration({
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
  }){
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

class MonthDecoration {
  final Color? hoverColor;
  final Color? focusColor;
  final TextStyle? selectedTextStyle;
  final TextStyle? unSelectedTextStyle;
  final TextStyle? disableTextStyle;
  final BoxDecoration? selectedDecoration;
  final BoxDecoration? focusDecoration;
  final BoxDecoration? unSelectedDecoration;

  MonthDecoration({
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

class DayDecoration {
  final Color? hoverColor;
  final TextStyle? disableTextStyle;
  final TextStyle? focusTextStyle;
  final TextStyle? selectedTextStyle;
  final TextStyle? unSelectedTextStyle;
  final BoxDecoration? focusDecoration;
  final BoxDecoration? selectedDecoration;
  final BoxDecoration? unSelectedDecoration;

  DayDecoration({
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
