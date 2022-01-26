import 'package:ef_steroid/models/form/form_field_model.dart';
import 'package:ef_steroid/views/widgets/shake_widget.dart';
import 'package:flutter/material.dart';

class SingleValueFormFieldModel<T> extends FormFieldModel {
  final ValueNotifier<T> valueNotifier;

  bool get hasValue => valueNotifier.value != null;

  SingleValueFormFieldModel.fromValue({
    required this.valueNotifier,
    ShakeController? shakeController,
  }) : super(
          shakeController: shakeController ?? ShakeController(),
        );

  @override
  void dispose() {
    valueNotifier.dispose();
  }
}
