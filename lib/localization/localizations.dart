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

import 'dart:convert';

import 'package:ef_steroid/helpers/context_helper.dart';
import 'package:ef_steroid/helpers/intl/language_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:quiver/strings.dart';

const kDefaultInterpolateParamKey = 'value';

class AL {
  Locale locale;
  static final Map<String, Map<String, dynamic>?> _cachedLocalisedValues = {};
  static Map<String, dynamic>? _localisedValues;
  static Future<void>? _loadLocalizationsDelegate;

  static final LocalizationsDelegate<AL> delegate = _ALDelegate();

  String get currentLanguage => locale.languageCode;

  AL(this.locale);

  static AL of(BuildContext? context) {
    context ??= ContextHelper.fallbackContext;
    return Localizations.of<AL>(context!, AL)!;
  }

  static Future<AL> loadAsync(Locale locale) async {
    final appTranslations = AL(locale);
    var assetName = locale.languageCode;
    if (isNotBlank(locale.scriptCode)) assetName += '_${locale.scriptCode}';
    if (isNotBlank(locale.countryCode)) assetName += '_${locale.countryCode}';

    if (!_cachedLocalisedValues.containsKey(assetName)) {
      await Future.wait([
        _loadI18nAsync(LanguageHelper.en),
        _loadI18nAsync(assetName),
      ]);
      _loadLocalizationsDelegate ??= Future(() async {
        await Future.wait(
          LanguageHelper.languages.keys
              .skipWhile((x) => _cachedLocalisedValues.keys.contains(x))
              .map((x) => _loadI18nAsync(x)),
        );
      });
    }
    _localisedValues = _cachedLocalisedValues[assetName];

    return appTranslations;
  }

  static Future<void> _loadI18nAsync(String assetName) async {
    final jsonStr = await rootBundle
        .loadString('lib/i18n/{0}.json'.replaceAll('{0}', assetName));
    _cachedLocalisedValues[assetName] = json.decode(jsonStr);
  }

  String text(String key, {Map<String, dynamic>? interpolateParams}) {
    var translation = _localisedValues![key];

    translation ??= _cachedLocalisedValues[LanguageHelper.en]![key];
    if (isNotBlank(translation) && interpolateParams != null) {
      translation = _assignArguments(translation, interpolateParams);
    }
    return (translation ?? key) ?? '';
  }

  String _assignArguments(
    String value,
    Map<String, dynamic> interpolateParams,
  ) {
    for (final key in interpolateParams.keys) {
      value = value.replaceAll('{$key}', '${interpolateParams[key]}');
    }

    return value;
  }
}

class _ALDelegate extends LocalizationsDelegate<AL> {
  @override
  bool isSupported(Locale locale) {
    var assetName = locale.languageCode;
    if (isNotBlank(locale.scriptCode)) assetName += '_${locale.scriptCode}';
    if (isNotBlank(locale.countryCode)) assetName += '_${locale.countryCode}';

    return LanguageHelper.languages.keys.contains(assetName);
  }

  @override
  Future<AL> load(Locale locale) {
    return AL.loadAsync(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AL> old) {
    return true;
  }
}
