import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:flutter/material.dart';
import 'package:tabbed_view/tabbed_view.dart';

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

  static bool isDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  static TabbedViewThemeData tabbedViewThemeData(BuildContext context) {
    final tabbedViewThemeData = ThemeHelper.isDarkMode(context)
        ? TabbedViewThemeData.dark(fontSize: 14)
        : TabbedViewThemeData.classic(fontSize: 14);

    const radius = Radius.circular(10.0);
    const borderRadius = BorderRadius.only(topLeft: radius, topRight: radius);

    tabbedViewThemeData.tab
      ..decoration = const BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: borderRadius,
      )
      ..padding = const EdgeInsets.all(8)
      ..margin = EdgeInsets.zero
      ..selectedStatus.decoration = BoxDecoration(
        color: Colors.grey[800],
        borderRadius: borderRadius,
      )
      ..highlightedStatus.decoration = const BoxDecoration(
        borderRadius: borderRadius,
      );

    tabbedViewThemeData.contentArea.padding = EdgeInsets.zero;
    tabbedViewThemeData.tabsArea.middleGap = 0;
    return tabbedViewThemeData;
  }

  static String getStringFromThemeKey(ThemeKey? value) {
    return (value ?? ThemeKey.followSystem).name;
  }
}

enum ThemeKey {
  dark,
  light,
  followSystem,
}

extension ThemeKeyExt on ThemeKey {
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeKey.dark:
        return ThemeMode.dark;
      case ThemeKey.light:
        return ThemeMode.light;
      case ThemeKey.followSystem:
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  /// This method takes [context] and retrieve the theme mode without
  /// [ThemeMode.system].
  ///
  /// [ThemeMode.system] will be parsed to the correct theme set on user device.
  ThemeMode toStrictThemeMode(BuildContext context) {
    final themeMode = toThemeMode();

    if (themeMode == ThemeMode.system) {
      switch (MediaQuery.of(context).platformBrightness) {
        case Brightness.dark:
          return ThemeMode.dark;
        case Brightness.light:
          return ThemeMode.light;
      }
    }
    return themeMode;
  }

  String toLocalizedString(BuildContext context) {
    switch (this) {
      case ThemeKey.dark:
        return AL.of(context).text('DarkTheme');
      case ThemeKey.light:
        return AL.of(context).text('LightTheme');
      case ThemeKey.followSystem:
        return AL.of(context).text('FollowSystem');
    }
  }
}
