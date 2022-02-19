import 'package:flutter/material.dart';
import 'package:ef_steroid/models/disposable.dart';

abstract class FormModel extends Disposable {
  final GlobalKey<FormState> formKey = GlobalKey();
}
