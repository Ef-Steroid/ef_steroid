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

import 'package:ef_steroid/services/navigation/navigation_service.dart';
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
