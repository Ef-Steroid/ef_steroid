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

import 'package:flutter/widgets.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/models/form/form_model.dart';
import 'package:meta/meta.dart';

mixin FormStateMixin<T extends StatefulWidget, TFormModel extends FormModel>
    on State<T> {
  /// The form.
  ///
  /// Subclass should provide this at a point, otherwise [validateInput]
  /// will crash.
  TFormModel? get form;

  /// ## Check if all the input fields in [form] are valid.
  ///
  /// Return the error message if the form is invalid; return null otherwise.
  @visibleForOverriding
  String? validateInput() {
    if (!form!.formKey.currentState!.validate()) {
      return getDefaultFormExceptionMessage();
    }
    return null;
  }

  @nonVirtual
  String getDefaultFormExceptionMessage() =>
      AL.of(context).text('PleaseFillAllRequiredField');

  @override
  void dispose() {
    // We allow the form here to be nullable since we cannot guarantee that
    // at this point the form is assigned.

    form?.dispose();
    super.dispose();
  }
}
