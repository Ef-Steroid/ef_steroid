import 'package:flutter/material.dart';

abstract class ColorConst {
  //#region: App Colors

  static const Color primaryColor = Color(0xff059bb6);

//#endregion
}

class ThemeHelper {
  static const circularProgressIndicatorColor =
      AlwaysStoppedAnimation<Color>(ColorConst.primaryColor);
}
