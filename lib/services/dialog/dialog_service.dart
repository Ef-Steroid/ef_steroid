import 'package:fast_dotnet_ef/services/navigation/navigation_service.dart';
import 'package:flutter/widgets.dart';

abstract class DialogService {
  Future<void> showDefaultDialog(
    BuildContext? context, {
    String? title,
    String? msg,
    String? okText,
  });

  Future<void> showErrorDialog(
    BuildContext? context,
    dynamic ex,
    StackTrace stackTrace,
  );

  /// [okText] defaults to 'OK'
  /// [cancelText] defaults to 'Cancel'
  Future<bool?> promptConfirmationDialog(
    BuildContext? context, {
    String? title,
    String? subtitle,
    String? okText,
    String? cancelText,
    bool useRootNavigator = false,
  });

  /// Show preference dialog.
  ///
  /// Do nothing if [NavigationService.navigatorKey] is not ready.
  Future<T?> showPreferenceDialog<T>();
}
