import 'package:flutter/material.dart';

abstract class NavigationService {
  /// Get the root navigatorKey.
  GlobalKey<NavigatorState> get navigatorKey;
}
