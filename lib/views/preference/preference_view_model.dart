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

import 'package:ef_steroid/helpers/intl/language_helper.dart';
import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:ef_steroid/views/home/home_view.dart';
import 'package:ef_steroid/views/view_model_base.dart';

class PreferenceViewModel extends ViewModelBase {
  PreferenceViewModel();

  void updateTheme({
    ThemeKey? theme,
  }) {
    HomeViewModelProvider.of(context)
        ?.homeViewModel
        .changeTheme(theme: theme ?? ThemeKey.followSystem);
  }

  void updateLanguage({
    String? locale,
  }) {
    HomeViewModelProvider.of(context)
        ?.homeViewModel
        .changeLanguage(locale: locale ?? LanguageHelper.en);
  }
}
