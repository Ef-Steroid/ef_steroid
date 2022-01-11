import 'package:fast_dotnet_ef/services/navigation/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NavigationService)
class AppNavigationService extends NavigationService {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
