import 'package:flutter/widgets.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/models/form/form_model.dart';
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
