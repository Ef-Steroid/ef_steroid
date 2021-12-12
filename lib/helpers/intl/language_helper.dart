import 'dart:ui';

import 'package:fast_dotnet_ef/app_settings.dart';
import 'package:intl/intl.dart';

class LanguageHelper {
  static const String en = 'en';
  static const String zhHans = 'zh_Hans';

  static const Map<String, _LocaleDetail> languages = {
    en: _LocaleDetail(
      name: 'English',
      locale: Locale('en'),
    ),
    zhHans: _LocaleDetail(
      name: '简体中文',
      locale: Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
      ),
    ),
  };

  static _LocaleDetail? get currentLanguage {
    return LanguageHelper.languages[AppSettings.prefLocale] ?? languages[en];
  }

  static String get dateLocale {
    switch (AppSettings.prefLocale) {
      case en:
        return Intl.defaultLocale ?? en;
      case zhHans:
        return 'zh';
    }
    throw UnsupportedError('Unsupported locale: ${AppSettings.prefLocale}');
  }

  static List<Locale> getSupportedLocales() {
    final supportedLocales = <Locale>[];
    for (final x in languages.values) {
      supportedLocales.add(x.locale);
    }
    return supportedLocales;
  }

  static String getSystemLocaleAsString() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    switch (deviceLocale.languageCode) {
      case LanguageHelper.en:
        return LanguageHelper.en;
      case 'zh':
        return LanguageHelper.zhHans;
      default:
        return LanguageHelper.en;
    }
  }

  static Locale getSystemLocale() {
    return languages[getSystemLocaleAsString()]!.locale;
  }
}

class _LocaleDetail {
  final String name;
  final Locale locale;

  const _LocaleDetail({
    required this.name,
    required this.locale,
  });
}
