library smart_date_field_picker;

export 'src/picker_decoration.dart';
export 'smart_date_field_picker.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_date_field_picker/src/overlay_builder.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

double defaultRadius = 8;

/// A customizable text field widget that allows users to pick a date from a dropdown-style overlay.
class SmartDateFieldPicker extends StatefulWidget {
  /// Controls the display of the dropdown overlay.
  final OverlayPortalController controller;

  /// Whether the field is enabled for user interaction.
  final bool enabled;

  /// Makes the field read-only (prevents typing if true).
  final bool? fieldReadOnly;

  /// Decoration for the input field.
  final InputDecoration? decoration;

  /// Optional offset to position the dropdown.
  final Offset? dropdownOffset;

  /// Callback triggered when a date is selected.
  final void Function(DateTime? value) onDateSelected;

  /// The initially selected date.
  final DateTime? initialDate;

  /// The earliest date the user can select.
  final DateTime? firstDate;

  /// The latest date the user can select.
  final DateTime? lastDate;

  /// Optional validator function for input validation.
  final String? Function(String?)? validator;

  /// Appearance and behavior customization options for the picker.
  final PickerDecoration? pickerDecoration;

  /// Focus node for managing field focus.
  final FocusNode? focusNode;

  /// When the validator function should be called.
  final AutovalidateMode? autoValidateMode;

  /// Whether the field is completely read-only (prevents both typing and dropdown).
  final bool readOnly;

  const SmartDateFieldPicker({
    super.key,
    this.lastDate,
    this.focusNode,
    this.validator,
    this.firstDate,
    this.fieldReadOnly,
    this.enabled = true,
    this.dropdownOffset,
    this.readOnly = false,
    this.autoValidateMode,
    this.pickerDecoration,
    required this.controller,
    this.decoration,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<SmartDateFieldPicker> createState() => SmartDateFieldPickerState();
}

class SmartDateFieldPickerState extends State<SmartDateFieldPicker> {
  /// Key used to get the position of the text field.
  final GlobalKey textFieldKey = GlobalKey();

  /// Link between the text field and the overlay for correct positioning.
  final layerLink = LayerLink();

  /// Flag to determine if typing should be disabled.
  bool isTypingDisabled = false;

  /// Controller to manage the text inside the field.
  final TextEditingController textController = TextEditingController();

  /// Key for the overlay content widget.
  final GlobalKey contentKey = GlobalKey();

  /// Focus node used internally (optional, as widget may also provide it).
  late FocusNode focusNode;

  /// Formatter to enforce a DD/MM/YYYY date format.
  late MaskTextInputFormatter maskFormatter;

  late DateTime firstDate;
  late DateTime lastDate;

  void _setupYearRange() {
    final currentYear = DateTime.now().year;

    if (widget.firstDate == null && widget.lastDate == null) {
      // Default: 12 years around initial date (or current year)
      firstDate = DateTime(currentYear - 6); // 6 before
      lastDate = DateTime(currentYear + 5); // 5 after (total 12 years)
    } else if (widget.firstDate != null && widget.lastDate == null) {
      // 12 years from firstDate
      firstDate = widget.firstDate!;
      lastDate = DateTime(firstDate.year + 11);
    } else if (widget.firstDate == null && widget.lastDate != null) {
      // 12 years ending at lastDate
      lastDate = widget.lastDate!;
      firstDate = DateTime(lastDate.year - 11);
    } else {
      // Use provided range
      firstDate = widget.firstDate!;
      lastDate = widget.lastDate!;
    }
  }

  @override
  void initState() {
    super.initState();

    /// Initialize the date mask formatter.
    maskFormatter = MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

    if (widget.initialDate != null) {
      textController.text =
          DateFormat("dd/MM/yyyy").format(widget.initialDate!);
    }
    _setupYearRange();
  }

  @override
  void didUpdateWidget(covariant SmartDateFieldPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialDate != oldWidget.initialDate) {
      if (widget.initialDate != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          textController.text =
              DateFormat("dd/MM/yyyy").format(widget.initialDate!);
          widget.onDateSelected(widget.initialDate!);

          maskFormatter = MaskTextInputFormatter(
              mask: '##/##/####',
              filter: {"#": RegExp(r'[0-9]')},
              type: MaskAutoCompletionType.lazy,
              initialText: textController.text
          );
          setState(() {});
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          textController.clear();
          widget.onDateSelected(null);
          setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: widget.controller,
      overlayChildBuilder: (context) {
        final RenderBox? textRenderBox =
            textFieldKey.currentContext?.findRenderObject() as RenderBox?;

        return GestureDetector(
          onTap: () {
            // Tapping outside should close the dropdown.
            widget.controller.hide();
          },
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                OverlayBuilder(
                  key: contentKey,
                  layerLink: layerLink,
                  renderBox: textRenderBox,
                  lastDate: lastDate,
                  firstDate: firstDate,
                  controller: widget.controller,
                  textController: textController,
                  initialDate: widget.initialDate,
                  dropdownOffset: widget.dropdownOffset,
                  pickerDecoration: widget.pickerDecoration,
                  onDateSelected: (value) {
                    widget.onDateSelected(value);
                    if (!widget.readOnly) {
                      widget.controller.hide();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: layerLink,
        child: Listener(
          onPointerDown: (PointerDownEvent event) {
            // Disable typing on right-click (secondary mouse button).
            if (event.buttons == kSecondaryMouseButton) {
              setState(() {
                isTypingDisabled = true;
              });
            } else {
              setState(() {
                isTypingDisabled = false;
              });
            }
          },
          child: TextFormField(
            key: textFieldKey,
            enabled: widget.enabled,
            controller: textController,
            validator: widget.validator,
            focusNode: widget.focusNode,
            onTap: () => textFiledOnTap(),
            inputFormatters: [maskFormatter],
            keyboardType: TextInputType.number,
            onChanged: (value) => dropDownOpen(),
            onFieldSubmitted: (value) => widget.controller.hide(),
            style: widget.pickerDecoration?.textStyle,
            onSaved: (newValue) {
              maskFormatter = MaskTextInputFormatter(
                  mask: '##/##/####',
                  filter: {"#": RegExp(r'[0-9]')},
                  type: MaskAutoCompletionType.lazy,
                  initialText: textController.text
              );
              setState(() {});
            },
            onEditingComplete: () {
              maskFormatter = MaskTextInputFormatter(
                  mask: '##/##/####',
                  filter: {"#": RegExp(r'[0-9]')},
                  type: MaskAutoCompletionType.lazy,
                  initialText: textController.text
              );
              setState(() {});
            },
            autovalidateMode: widget.autoValidateMode,
            showCursor: widget.pickerDecoration?.showCursor,
            cursorHeight: widget.pickerDecoration?.cursorHeight,
            cursorRadius: widget.pickerDecoration?.cursorRadius,
            cursorWidth: widget.pickerDecoration?.cursorWidth ?? 2.0,
            decoration: widget.decoration ?? const InputDecoration(),
            textAlign: widget.pickerDecoration?.textAlign ?? TextAlign.start,
            cursorColor: widget.pickerDecoration?.cursorColor ?? Colors.black,
            readOnly: isTypingDisabled
                ? true
                : widget.fieldReadOnly ?? widget.readOnly,
            cursorErrorColor:
                widget.pickerDecoration?.cursorErrorColor ?? Colors.black,
            enableInteractiveSelection:
                widget.pickerDecoration?.enableInteractiveSelection ??
                    (!(widget.fieldReadOnly ?? false)),
          ),
        ),
      ),
    );
  }

  /// Handles tap on the input field to show the date picker overlay.
  void textFiledOnTap() {

    if (!widget.readOnly) {
      maskFormatter = MaskTextInputFormatter(
          mask: '##/##/####',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
          initialText: textController.text
      );

      setState(() {});
      widget.controller.show();
    }
  }

  /// Shows the dropdown if not already shown and field is editable.
  void dropDownOpen() {
    if (!widget.readOnly && !widget.controller.isShowing) {
      widget.controller.show();

    }
  }
}
