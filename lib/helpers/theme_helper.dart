import 'package:flutter/material.dart';

enum ThemeKey {
  dark,
  light,
  followSystem,
}

abstract class ColorConst {
  //#region: App Colors

  static const Color primaryColor = Colors.teal;
  static const Color accentColor = Colors.tealAccent;

  static const Color dangerColor = Colors.redAccent;
  static const Color warningColor = Colors.amber;

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
        inputDecorationTheme: _inputDecorationTheme,
        buttonTheme: _buttonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        floatingActionButtonTheme: _floatingActionButtonTheme,
        elevatedButtonTheme: _elevatedButtonThemeData,
        tooltipTheme: _tooltipTheme,
      ),
      ThemeKey.light: ThemeData.light().copyWith(
        brightness: Brightness.light,
        primaryColor: ColorConst.primaryColor,
        inputDecorationTheme: _inputDecorationTheme,
        buttonTheme: _buttonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        floatingActionButtonTheme: _floatingActionButtonTheme,
        elevatedButtonTheme: _elevatedButtonThemeData,
        tooltipTheme: _tooltipTheme,
      ),
    };
  }

  static const InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    labelStyle: TextStyle(
      color: ColorConst.primaryColor,
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: ColorConst.primaryColor,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: ColorConst.primaryColor,
      ),
    ),
  );

  static const TooltipThemeData _tooltipTheme = TooltipThemeData(
    waitDuration: Duration(milliseconds: 300),
  );
  static const ButtonThemeData _buttonTheme = ButtonThemeData(
    buttonColor: ColorConst.primaryColor,
  );

  static const FloatingActionButtonThemeData _floatingActionButtonTheme =
      FloatingActionButtonThemeData(
    backgroundColor: ColorConst.primaryColor,
    foregroundColor: Colors.white,
  );

  static final ElevatedButtonThemeData _elevatedButtonThemeData =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      shadowColor: Colors.transparent,
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: const StadiumBorder(),
      side: const BorderSide(
        color: ColorConst.primaryColor,
      ),
      primary: ColorConst.primaryColor,
    ),
  );
  static const circularProgressIndicatorColor =
      AlwaysStoppedAnimation<Color>(ColorConst.primaryColor);
}
