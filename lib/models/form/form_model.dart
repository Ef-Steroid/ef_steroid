import 'package:flutter/material.dart';
import 'package:fast_dotnet_ef/models/disposable.dart';

abstract class FormModel extends Disposable {
  final GlobalKey<FormState> formKey = GlobalKey();
}
