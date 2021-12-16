
import 'package:fast_dotnet_ef/exceptions/app_exception.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/models/form/form_model.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';

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
  }

  @nonVirtual
  String getDefaultFormExceptionMessage() =>
      AL.of(context).text('PleaseFillAllRequiredField');

  @override
  void dispose() {
    // We allow the form here to be nullable due to we cannot guarantee that
    // at this point the form is assigned.

    form?.dispose();
    super.dispose();
  }
}
