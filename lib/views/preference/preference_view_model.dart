import 'package:fast_dotnet_ef/helpers/intl/language_helper.dart';
import 'package:fast_dotnet_ef/helpers/theme_helper.dart';
import 'package:fast_dotnet_ef/views/home/home_view.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';

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
