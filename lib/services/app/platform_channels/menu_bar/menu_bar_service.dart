import 'package:fast_dotnet_ef/app_consts.dart';
import 'package:flutter/services.dart';

abstract class MenuBarService {
  static const MethodChannel methodChannel =
      MethodChannel('''${AppConsts.appPackageName}/MenuBarService''');

  void setup();
}