import 'dart:async';

import 'package:ef_steroid/app_settings.dart';
import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:ef_steroid/views/view_model_base.dart';

class Preference {
  final ThemeKey theme;

  final String locale;

  const Preference({
    required this.theme,
    required this.locale,
  });

  Preference copyWith({
    ThemeKey? theme,
    String? locale,
  }) {
    return Preference(
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
    );
  }
}

class HomeViewModel extends ViewModelBase {
  final StreamController<Preference> _preferenceStreamCtrl =
      StreamController.broadcast();

  Stream<Preference>? _preferenceStream;

  Stream<Preference> get preferenceStream =>
      _preferenceStream ??= _preferenceStreamCtrl.stream;

  late StreamSubscription _preferenceStreamSubscription;
  Preference _currentPreference = Preference(
    theme: AppSettings.prefTheme,
    locale: AppSettings.prefLocale,
  );

  Preference get currentPreference => _currentPreference;

  HomeViewModel() {
    _preferenceStreamSubscription = preferenceStream.listen((event) {
      _currentPreference = event;
    });
  }

  @override
  void dispose() {
    _preferenceStreamSubscription.cancel();
    _preferenceStreamCtrl.close();
    super.dispose();
  }

  void changeTheme({
    required ThemeKey theme,
  }) {
    _preferenceStreamCtrl.add(
      _currentPreference.copyWith(
        theme: theme,
      ),
    );
    AppSettings.setPrefTheme(theme);
  }

  void changeLanguage({
    required String locale,
  }) {
    _preferenceStreamCtrl.add(
      _currentPreference.copyWith(
        locale: locale,
      ),
    );
    AppSettings.setPrefLocale(locale);
  }
}
