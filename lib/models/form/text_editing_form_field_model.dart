/*
 * Copyright 2022-2022 MOK KAH WAI and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:ef_steroid/views/widgets/shake_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:ef_steroid/models/form/form_field_model.dart';

class TextEditingFormFieldModel extends FormFieldModel {
  final TextEditingController textEditingController;

  TextEditingFormFieldModel()
      : textEditingController = TextEditingController(),
        super(shakeController: ShakeController());

  TextEditingFormFieldModel.fromValue({
    required this.textEditingController,
    ShakeController? shakeController,
  }) : super(shakeController: shakeController ?? ShakeController());

  @override
  void dispose() {
    textEditingController.dispose();
    shakeController.dispose();
  }

  /// Return the [TextEditingController.text].
  String toText() => textEditingController.text;
}
