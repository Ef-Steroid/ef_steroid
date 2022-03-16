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

import 'package:ef_steroid/exceptions/app_exception.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/models/form/form_model.dart';
import 'package:ef_steroid/views/view_model_base.dart';

import 'package:meta/meta.dart';

/// Form view model mixin for single form.
///
/// Use [SwitchableMultipleFormsViewModelMixin] for single but switchable forms.
///
/// A change to the current class should reflect the change to
/// [SwitchableMultipleFormsViewModelMixin] as well.
mixin FormViewModelMixin<TFormModel extends FormModel> on ViewModelBase {
  /// The form.
  ///
  /// Subclass should provide this at a point, otherwise [validateInput]
  /// will crash.
  TFormModel? get form;

  /// {@template form_view_model_mixin.checkInput}
  ///
  /// ## Check if all the input fields in [form] are valid.
  ///
  /// {@endtemplate}
  ///
  /// If any of them is invalid, throw [UserFriendlyException].
  ///
  /// Override this method to customize the logic for [form] input validation.
  /// ---
  /// Consider overriding [validateInput] if you want to customize the
  /// exception message.
  @protected
  void checkInput() {
    final validateInputResult = validateInput();

    if (validateInputResult != null) {
      throw UserFriendlyException(validateInputResult);
    }
  }

  /// {@macro form_view_model_mixin.checkInput}
  ///
  /// Return true if the form is valid; false otherwise.
  @nonVirtual
  bool checkCanProceed() {
    final validateInputResult = validateInput();
    // We respect the possibility of empty string error message.

    return validateInputResult == null;
  }

  /// {@macro form_view_model_mixin.checkInput}
  ///
  /// Return the error message if the form is invalid; return null otherwise.
  ///
  /// Override this method to customize the exception message.
  /// ---
  /// Consider overriding [checkInput] if you want to customize the
  /// logic for [form] input validation.
  @protected
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
