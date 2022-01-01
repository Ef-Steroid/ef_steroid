import 'package:fast_dotnet_ef/services/app/platform_channels/menu_bar/menu_bar_service.dart';
import 'package:fast_dotnet_ef/services/app/platform_channels/platform_channel_keys.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: MenuBarService)
class AppMenuBarService extends MenuBarService {
  final LogService _logService;

  AppMenuBarService(
    this._logService,
  );

  @override
  void setup() {
    MenuBarService.methodChannel.setMethodCallHandler(_onMethodCallAsync);
  }

  Future<dynamic> _onMethodCallAsync(MethodCall call) async {
    if (call.method == PlatformChannelKeys.openPreferenceKey) {
      _logService.info('Dart receive open preference signal: ');
    }
  }
}
