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

  // helper to create mask formatter in one place
  MaskTextInputFormatter _createMask({String? initialText}) {
    return MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
      initialText: initialText,
    );
  }

  void _setupYearRange() {
    // Goal:
    // - If both firstDate and lastDate provided: use them.
    // - If only firstDate provided: make a 12-year window starting from firstDate.year
    // - If only lastDate provided: make a 12-year window ending at lastDate.year
    // - If neither provided:
    //    * if widget.initialDate != null -> make a 12-year window centered on initialDate.year
    //    * else -> make a 12-year window centered on current year
    final currentYear = DateTime.now().year;

    if (widget.firstDate != null && widget.lastDate != null) {
      firstDate = widget.firstDate!;
      lastDate = widget.lastDate!;
      return;
    }

    if (widget.firstDate != null && widget.lastDate == null) {
      firstDate = widget.firstDate!;
      lastDate = DateTime(firstDate.year + 11, 12, 31);
      return;
    }

    if (widget.firstDate == null && widget.lastDate != null) {
      lastDate = widget.lastDate!;
      firstDate = DateTime(lastDate.year - 11, 1, 1);
      return;
    }

    // Neither firstDate nor lastDate provided.
    if (widget.initialDate != null) {
      // Use initialDate's year as center. Make range start at initialYear - 6 and end at initialYear + 5.
      final initialYear = widget.initialDate!.year;
      firstDate = DateTime(initialYear - 6, 1, 1);
      lastDate = DateTime(initialYear + 5, 12, 31);
    } else {
      // No initialDate: center around currentYear.
      firstDate = DateTime(currentYear - 6, 1, 1);
      lastDate = DateTime(currentYear + 5, 12, 31);
    }
  }

  @override
  void initState() {
    super.initState();

    // focusNode: either use provided or create one we own
    focusNode = widget.focusNode ?? FocusNode();

    // Setup mask formatter with initial text (if any)
    if (widget.initialDate != null) {
      textController.text =
          DateFormat("dd/MM/yyyy").format(widget.initialDate!);
    }
    maskFormatter = _createMask(initialText: textController.text);

    _setupYearRange();
  }

  @override
  void didUpdateWidget(covariant SmartDateFieldPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the initialDate changed, update text and mask.
    if (widget.initialDate != oldWidget.initialDate) {
      // Use postFrame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // If parent cleared the initialDate (set to null) -> clear field & reset mask
        if (widget.initialDate == null) {
          if (textController.text.isNotEmpty) {
            textController.clear();
          }
          // Notify parent that date is cleared
          widget.onDateSelected(null);

          // Reset mask to empty initial text
          maskFormatter = _createMask(initialText: "");

          // Update UI
          if (mounted) setState(() {});
          return;
        }

        // Otherwise initialDate is non-null -> set properly formatted text
        final newText = DateFormat("dd/MM/yyyy").format(widget.initialDate!);

        // Only update if different (avoids unnecessary rebuilds)
        if (textController.text != newText) {
          textController.text = newText;
          textController.selection =
              TextSelection.collapsed(offset: newText.length);
        }

        // Notify parent of the selected date (keeps behavior same as before)
        widget.onDateSelected(widget.initialDate!);

        // Update mask to match new text
        maskFormatter = _createMask(initialText: newText);

        if (mounted) setState(() {});
      });
    }

    // If firstDate/lastDate props changed, recompute range
    if (widget.firstDate != oldWidget.firstDate ||
        widget.lastDate != oldWidget.lastDate) {
      _setupYearRange();
      setState(() {});
    }
  }

  @override
  void dispose() {
    try {
      textController.dispose();
    } catch (_) {}
    // Only dispose focusNode if we created it (i.e., widget.focusNode was null).
    if (widget.focusNode == null) {
      try {
        focusNode.dispose();
      } catch (_) {}
    }
    super.dispose();
  }

  /// Try to parse the current text (dd/MM/yyyy). If valid and within [firstDate,lastDate],
  /// call onDateSelected(parsed) and hide overlay (unless widget.readOnly).
  void _trySetDateFromText() {
    final text = textController.text.trim();
    if (text.isEmpty) {
      // If empty, consider it as clearing the date
      widget.onDateSelected(null);
      if (!widget.readOnly) widget.controller.hide();
      return;
    }

    try {
      // Parse using exact format; throws if invalid
      final parsed = DateFormat('dd/MM/yyyy').parseStrict(text);

      // Normalize parsed to a DateTime with zeroed time (optional)
      final parsedDate = DateTime(parsed.year, parsed.month, parsed.day);

      // Range checks (if you want inclusive bounds)
      if (parsedDate.isBefore(firstDate)) {
        // Too early
        textController.clear();
        widget.onDateSelected(null);
        throw 'Selected date is earlier than allowed. Minimum allowed date: ${DateFormat('dd/MM/yyyy').format(firstDate)}';
      }

      if (parsedDate.isAfter(lastDate)) {
        // Too late
        textController.clear();
        widget.onDateSelected(null);
        throw 'Selected date is later than allowed. Maximum allowed date: ${DateFormat('dd/MM/yyyy').format(lastDate)} — you cannot select a date beyond this.';
      }

      // If valid, update controller text (to normalized form) and notify parent
      final newText = DateFormat('dd/MM/yyyy').format(parsedDate);
      textController.text = newText;
      // Move cursor to end
      textController.selection =
          TextSelection.collapsed(offset: newText.length);

      // Update mask so formatting stays consistent
      maskFormatter = _createMask(initialText: newText);

      // Notify
      widget.onDateSelected(parsedDate);

      // Hide overlay if not read-only
      if (!widget.readOnly) {
        widget.controller.hide();
      }
    } on FormatException catch (_) {
      // Parsing failed (invalid date)
      textController.clear();
      widget.onDateSelected(null);

      rethrow;
      // Do not clear — let user correct input
    } catch (e) {
      // Generic fallback error, show brief message
      textController.clear();
      widget.onDateSelected(null);
      rethrow;
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
            // if(textController.text.isEmpty){
            //   textController.clear();
            //   widget.onDateSelected(null);
            // }
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
            onChanged: (value) {
              // Always try to open dropdown when user types
              dropDownOpen();

              // Get unmasked value (only digits)
              final unmasked = maskFormatter.getUnmaskedText();

              // For mask '##/##/####' we expect 8 digits (ddmmyyyy)
              if (unmasked.length == 8) {
                // _trySetDateFromText() in your code throws on invalid input.
                // Catch exceptions here to avoid uncaught exceptions while typing.
                try {
                  _trySetDateFromText();
                } catch (_) {

                }
              }

              if(value.isEmpty){
                  textController.clear();
                  widget.onDateSelected(null);
              }
            },

            style: widget.pickerDecoration?.textStyle,
            onSaved: (newValue) {
              maskFormatter = MaskTextInputFormatter(
                  mask: '##/##/####',
                  filter: {"#": RegExp(r'[0-9]')},
                  type: MaskAutoCompletionType.lazy,
                  initialText: textController.text);
              setState(() {});
            },

            onFieldSubmitted: (value) {
              widget.controller.hide();
              // When user presses Enter / Submit on keyboard
              _trySetDateFromText();
            },
            onEditingComplete: () {
              widget.controller.hide();
              // Called when editing finishes (also handle same behavior)
              _trySetDateFromText();
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
          initialText: textController.text);

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
