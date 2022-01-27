import 'package:fast_dotnet_ef/services/app/platform_channels/menu_bar/menu_bar_service.dart';
import 'package:fast_dotnet_ef/services/app/platform_channels/platform_channel_keys.dart';
import 'package:fast_dotnet_ef/services/dialog/dialog_service.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: MenuBarService)
class AppMenuBarService extends MenuBarService {
  final LogService _logService;
  final DialogService _dialogService;

  AppMenuBarService(
    this._logService,
    this._dialogService,
  );

  @override
  void setup() {
    MenuBarService.methodChannel.setMethodCallHandler(_onMethodCallAsync);
  }

  Future<dynamic> _onMethodCallAsync(MethodCall call) async {
    if (call.method == PlatformChannelKeys.openPreferenceKey) {
      return _openPreferenceAsync();
    }
  }

  Future<void> _openPreferenceAsync() {
    _logService.info('Start opening preference');
    return _dialogService.showPreferenceDialog();
  }
}
