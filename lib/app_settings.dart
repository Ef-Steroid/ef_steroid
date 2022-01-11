import 'package:fast_dotnet_ef/app_consts.dart';
import 'package:fast_dotnet_ef/helpers/intl/language_helper.dart';
import 'package:fast_dotnet_ef/helpers/theme_helper.dart';
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
