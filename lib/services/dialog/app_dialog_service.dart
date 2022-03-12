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

import 'dart:async';
import 'dart:ui';

import 'package:ef_steroid/exceptions/app_exception.dart';
import 'package:ef_steroid/helpers/animation_helper.dart';
import 'package:ef_steroid/helpers/context_helper.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/services/dialog/dialog_service.dart';
import 'package:ef_steroid/services/log/log_service.dart';
import 'package:ef_steroid/services/navigation/navigation_service.dart';
import 'package:ef_steroid/views/preference/preference_view.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

typedef _OnErrorCallback = Future<void> Function(
  BuildContext context,
  String title,
  String message,
);

@Injectable(as: DialogService)
class AppDialogService extends DialogService {
  final LogService _logService;
  final NavigationService _navigationService;

  AppDialogService(
    this._logService,
    this._navigationService,
  );

  @override
  Future<void> showDefaultDialog(
    BuildContext? context, {
    String? title,
    String? msg,
    String? okText,
  }) {
    return showGeneralDialog<void>(
      context: context ?? ContextHelper.fallbackContext!,
      useRootNavigator: true,
      transitionDuration: AnimationHelper.standardAnimationDuration,
      barrierDismissible: false,
      transitionBuilder: AnimationHelper.dialogTransitionBuilder,
      pageBuilder: (context, _, __) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          title: Text(title ?? ''),
          content: Text(msg ?? ''),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AL.of(context).text('OK')),
            ),
          ],
        );
      },
    );
  }

  @override
  Future<void> showErrorDialog(
    BuildContext? context,
    dynamic ex,
    StackTrace stackTrace,
  ) async =>
      _showErrorCoreAsync(
        context,
        ex,
        stackTrace,
        (
          BuildContext context,
          String title,
          String message,
        ) =>
            showDefaultDialog(
          context,
          title: title,
          msg: message,
        ),
      );

  Future<void> _showErrorCoreAsync(
    BuildContext? context,
    dynamic ex,
    StackTrace stackTrace,
    _OnErrorCallback onError,
  ) {
    context ??= ContextHelper.fallbackContext!;
    final title = AL.of(context).text('SomethingWentWrong');
    var shouldReportError = true;
    String message = '';

    if (ex is Error) {
      message = ex.toString();
    } else if (ex is Exception) {
      if (ex is UserFriendlyException) {
        shouldReportError = false;
        message = ex.message;
      } else {
        message = ex.toString();
      }
    } else {
      message = ex.toString();
    }

    return Future.wait([
      onError(
        context,
        title,
        message,
      ),
      if (shouldReportError)
        Future(() {
          _logService.severe(
            ex,
            stackTrace,
          );
        }),
    ]);
  }

  @override
  Future<bool?> promptConfirmationDialog(
    BuildContext? context, {
    String? title,
    String? subtitle,
    String? okText,
    String? cancelText,
    bool useRootNavigator = false,
  }) {
    return showGeneralDialog<bool>(
      context: context!,
      barrierDismissible: false,
      useRootNavigator: useRootNavigator,
      transitionDuration: AnimationHelper.standardAnimationDuration,
      transitionBuilder: AnimationHelper.dialogTransitionBuilder,
      pageBuilder: (context, _, __) => _PromptConfirmationDialog(
        title: title,
        subtitle: subtitle,
        okText: okText,
        cancelText: cancelText,
      ),
    );
  }

  @override
  Future<T?> showPreferenceDialog<T>() {
    final context = ContextHelper.fallbackContext;
    if (context == null) return Future.value();

    final navigatorState = _navigationService.navigatorKey.currentState;
    if (navigatorState == null) return Future.value();
    return navigatorState.push<T>(
      RawDialogRoute<T>(
        pageBuilder: (context, _, __) => const PreferenceView(),
        barrierDismissible: false,
        transitionDuration: AnimationHelper.standardAnimationDuration,
        transitionBuilder: AnimationHelper.dialogTransitionBuilder,
      ),
    );
  }
}

class _PromptConfirmationDialog extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? okText;
  final String? cancelText;
  final ScrollController scrollController = ScrollController();

  _PromptConfirmationDialog({
    Key? key,
    this.title,
    this.subtitle,
    this.okText,
    this.cancelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const blurValue = 5.0;

    final l = AL.of(context).text;
    final textTheme = Theme.of(context).textTheme;

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaY: blurValue,
        sigmaX: blurValue,
      ),
      child: AlertDialog(
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        title: Text(title ?? ''),
        content: Scrollbar(
          controller: scrollController,
          isAlwaysShown: true,
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    subtitle ?? '',
                    style: textTheme.subtitle2,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(false);
            },
            child: Text(
              (cancelText ?? l('Cancel').toUpperCase()),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text(
              okText?.toUpperCase() ?? l('OK'),
            ),
          ),
        ],
      ),
    );
  }
}
