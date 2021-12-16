import 'package:flutter/material.dart';

enum ThemeKey {
  dark,
  light,
  followSystem,
}

abstract class ColorConst {
  //#region: App Colors

  static const Color primaryColor = Color(0xff059bb6);

//#endregion
}

class ThemeHelper {
  late Map<ThemeKey, ThemeData> themes;

  static final ThemeHelper instance = ThemeHelper._();

  ThemeHelper._() {
    _setupTheme();
  }

  void _setupTheme() {
    themes = {
      ThemeKey.dark: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        primaryColor: ColorConst.primaryColor,
        tooltipTheme: _tooltipTheme,
      ),
      ThemeKey.light: ThemeData.light().copyWith(
        brightness: Brightness.light,
        primaryColor: ColorConst.primaryColor,
        tooltipTheme: _tooltipTheme,
      ),
    };
  }

  static const TooltipThemeData _tooltipTheme = TooltipThemeData(
    waitDuration: Duration(milliseconds: 300),
  );
  static const circularProgressIndicatorColor =
      AlwaysStoppedAnimation<Color>(ColorConst.primaryColor);
}
