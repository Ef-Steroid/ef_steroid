import 'package:fast_dotnet_ef/views/widgets/shake_widget.dart';
import 'package:flutter/material.dart';
import 'package:fast_dotnet_ef/models/disposable.dart';

abstract class FormFieldModel extends Disposable {
  final GlobalKey<FormFieldState> fieldKey = GlobalKey();

  final ShakeController shakeController;

  FormFieldModel({
    required this.shakeController,
  });
}
