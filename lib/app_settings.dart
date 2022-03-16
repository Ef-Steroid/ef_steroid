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

import 'package:ef_steroid/app_consts.dart';
import 'package:ef_steroid/helpers/intl/language_helper.dart';
import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:quiver/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static SharedPreferences? sp;
  static AppSettings instance = AppSettings._();

  AppSettings._();

  Future<void> setup() async {
    sp ??= await SharedPreferences.getInstance();

    if (AppSettings.appSettingsVersion < AppConsts.appSettingsVersion) {
      await clearSettings();
      await AppSettings.setAppSettingsVersion(AppConsts.appSettingsVersion);
    }
  }

  static Future<void> clearSettings() async {
    await sp!.clear();
  }

  //#region: Preferences.

  static const String prefLocaleKey = 'Preferences.Language';

  static String get prefLocale {
    if (isBlank(sp!.getString(prefLocaleKey))) {
      return LanguageHelper.getSystemLocaleAsString();
    }

    var prefLocale = sp!.getString(prefLocaleKey) ?? '';
    if (LanguageHelper.languages.keys.contains(prefLocale)) return prefLocale;

    // Fallback to English if the prefLocale can't be found.

    prefLocale = LanguageHelper.en;
    sp!.setString(prefLocaleKey, prefLocale);
    return prefLocale;
  }

  static Future<void> setPrefLocale(String value) =>
      sp!.setString(prefLocaleKey, value);

  static const String prefThemeKey = 'User.prefTheme';

  static ThemeKey get prefTheme {
    final prefThemeName = sp!.getString(prefThemeKey);
    return (prefThemeName == null
            ? null
            : ThemeKey.values.byName(prefThemeName)) ??
        ThemeKey.followSystem;
  }

  static Future<void> setPrefTheme(ThemeKey? value) =>
      sp!.setString(prefThemeKey, ThemeHelper.getStringFromThemeKey(value));

  //#endregion

  //#region: App

  static const appSettingsVersionKey = 'App.AppSettingsVersion';

  /// See [AppConsts.appSettingsVersion] for detail.
  static int get appSettingsVersion => sp!.getInt(appSettingsVersionKey) ?? -1;

  static Future<void> setAppSettingsVersion(int value) =>
      sp!.setInt(appSettingsVersionKey, value);

//#endregion
}
