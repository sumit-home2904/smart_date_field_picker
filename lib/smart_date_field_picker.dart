library smart_date_field_picker;

export 'src/picker_decoration.dart';
export 'smart_date_field_picker.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smart_date_field_picker/src/overlay_builder.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class SmartDateFieldPicker extends StatefulWidget {
  /// Controller for showing or hiding the dropdown overlay.
  final OverlayPortalController controller;
  final bool enabled;
  final bool? fieldReadOnly;
  final InputDecoration? decoration;
  final Offset? dropdownOffset;
  final void Function(DateTime? value) onDateSelected;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  // final double? height,width;
  final String? Function(String?)? validator;
  final PickerDecoration? pickerDecoration;

  final FocusNode? focusNode;
  /// Specifies when the validator function should be called.
  ///
  /// Defaults to null.
  final AutovalidateMode? autoValidateMode;


  /// Whether the field is read-only and input is only allowed from the dropdown.
  final bool readOnly;

  SmartDateFieldPicker({
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
    required this.decoration,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<SmartDateFieldPicker> createState() => _SmartDateFieldPickerState();
}

class _SmartDateFieldPickerState extends State<SmartDateFieldPicker> {
  /// Key for the main text field widget.
  final GlobalKey textFieldKey = GlobalKey();

  /// Layer link used to position the dropdown overlay.
  final layerLink = LayerLink();

  /// Whether typing in the input field is disabled.
  bool isTypingDisabled = false;

  final TextEditingController textController = TextEditingController();

  final GlobalKey contentKey = GlobalKey();

  late FocusNode focusNode;

  late final MaskTextInputFormatter maskFormatter;

  @override
  void initState() {
    super.initState();
    maskFormatter = MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }



  @override
  Widget build(BuildContext context) {
    return  OverlayPortal(
        controller: widget.controller,
        overlayChildBuilder: (context) {
          final RenderBox? textRenderBox = textFieldKey.currentContext?.findRenderObject() as RenderBox?;

          return GestureDetector(
            onTap: () {
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
                    lastDate: widget.lastDate,
                    firstDate: widget.firstDate,
                    controller: widget.controller,
                    textController: textController,
                    initialDate: widget.initialDate,
                    dropdownOffset: widget.dropdownOffset,
                    pickerDecoration: widget.pickerDecoration,
                    onDateSelected: (value) {
                      widget.onDateSelected(value);
                      if (!(widget.readOnly)) {
                        widget.controller.hide();
                      }
                    },
                  )
                ],
              ),
            ),
          );
        },
        child: CompositedTransformTarget(
          link: layerLink,
          child: Listener(
              onPointerDown: (PointerDownEvent event) {
                if (event.buttons == kSecondaryMouseButton) {
                  // Disable typing on secondary mouse button press
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
                autovalidateMode: widget.autoValidateMode,
                showCursor: widget.pickerDecoration?.showCursor,
                cursorHeight: widget.pickerDecoration?.cursorHeight,
                cursorRadius: widget.pickerDecoration?.cursorRadius,
                cursorWidth: widget.pickerDecoration?.cursorWidth ?? 2.0,
                decoration: (widget.decoration ?? const InputDecoration()),
                textAlign: widget.pickerDecoration?.textAlign ?? TextAlign.start,
                cursorColor: widget.pickerDecoration?.cursorColor ?? Colors.black,
                readOnly: isTypingDisabled ? true : widget.fieldReadOnly ?? widget.readOnly,
                cursorErrorColor: widget.pickerDecoration?.cursorErrorColor ?? Colors.black,
                enableInteractiveSelection: widget.pickerDecoration?.enableInteractiveSelection ?? (!(widget.fieldReadOnly ?? false)),
              )),
        ),
    );
  }

  /// drop-down on tap function
  textFiledOnTap() async {
    if (!(widget.readOnly)) {
      widget.controller.show();
    }
  }

  ///open drop down when any event trigger.
  dropDownOpen() {
    if (!(widget.readOnly)) {
      if (!widget.controller.isShowing) {
        widget.controller.show();
      }
    }
  }
}
