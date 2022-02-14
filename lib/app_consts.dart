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
