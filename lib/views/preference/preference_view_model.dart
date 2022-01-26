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
