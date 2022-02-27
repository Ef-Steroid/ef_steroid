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

import 'package:ef_steroid/app_settings.dart';

class AppConsts {
  /// This is used to record the current version of [AppSettings]. If
  /// breaking changes to [AppSettings] structure is introduced, update this
  /// version to force clearing all [AppSettings] upon first app launch.
  ///
  /// - See [AppSettings.setup] for clearing implementation.
  static const int appSettingsVersion = 1;

  /// The package name of this app.
  ///
  /// This is typically used in:
  /// - [MethodChannel]
  static const String appPackageName = 'com.techcreator.EfSteroid';
}
