import 'package:ef_steroid/views/widgets/shake_widget.dart';
import 'package:flutter/material.dart';
import 'package:ef_steroid/models/disposable.dart';

abstract class FormFieldModel extends Disposable {
  final GlobalKey<FormFieldState> fieldKey = GlobalKey();

  final ShakeController shakeController;

  FormFieldModel({
    required this.shakeController,
  });
}
