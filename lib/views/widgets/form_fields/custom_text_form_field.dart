import 'package:ef_steroid/models/form/text_editing_form_field_model.dart';
import 'package:ef_steroid/views/widgets/shake_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingFormFieldModel? formField;
  final int? maxLines;
  final FocusNode? focusNode;
  final InputDecoration inputDecoration;
  final TextInputAction? textInputAction;
  final TextAlignVertical? textAlignVertical;
  final FormFieldValidator<String>? validator;
  final String? initialValue;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final bool autofocus;
  final bool readOnly;
  final ToolbarOptions? toolbarOptions;
  final bool? showCursor;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFormField({
    Key? key,
    this.formField,
    this.maxLines = 1,
    this.focusNode,
    this.inputDecoration = const InputDecoration(),
    this.textInputAction,
    this.textAlignVertical,
    this.validator,
    this.initialValue,
    this.keyboardType,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.toolbarOptions,
    this.showCursor,
    this.smartDashesType,
    this.smartQuotesType,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.enabled,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.readOnly = false,
    this.obscureText = false,
    this.expands = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLengthEnforcement = MaxLengthEnforcement.enforced,
    this.enableInteractiveSelection = true,
    this.cursorWidth = 2.0,
    this.obscuringCharacter = '•',
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget widget = TextFormField(
      key: formField?.fieldKey,
      controller: formField?.textEditingController,
      maxLines: maxLines,
      focusNode: focusNode,
      textAlignVertical: textAlignVertical,
      decoration: inputDecoration,
      textInputAction: textInputAction,
      validator: validator,
      style: style ?? textTheme.bodyText1,
      keyboardType: keyboardType,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
      toolbarOptions: toolbarOptions,
      readOnly: readOnly,
      showCursor: showCursor,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText,
      autocorrect: autocorrect,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      enableSuggestions: enableSuggestions,
      maxLengthEnforcement: maxLengthEnforcement,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      enabled: enabled ?? inputDecoration.enabled,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      scrollPadding: scrollPadding,
      scrollPhysics: scrollPhysics,
      keyboardAppearance: keyboardAppearance,
      enableInteractiveSelection: enableInteractiveSelection,
      buildCounter: buildCounter,
      autofillHints: autofillHints,
      initialValue: initialValue,
      onSaved: onSaved,
    );

    if (formField != null) {
      widget = ShakeWidget(
        shakeController: formField!.shakeController,
        child: widget,
      );
    }
    return widget;
  }
}
