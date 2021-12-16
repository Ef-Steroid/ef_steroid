import 'package:fast_dotnet_ef/views/widgets/shake_widget.dart';
import 'package:flutter/material.dart';
import 'package:fast_dotnet_ef/models/form/single_value_form_field_model.dart';

class DropDownFormFieldModel<T> extends SingleValueFormFieldModel<T> {
  DropDownFormFieldModel.fromValue({
    required ValueNotifier<T> valueNotifier,
    ShakeController? shakeController,
  }) : super.fromValue(
          valueNotifier: valueNotifier,
          shakeController: shakeController ?? ShakeController(),
        );
}
