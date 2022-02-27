/*
 * Copyright 2022-2022 MOK KAH WAI and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:ef_steroid/services/app/platform_channels/menu_bar/menu_bar_service.dart';
import 'package:ef_steroid/services/app/platform_channels/platform_channel_keys.dart';
import 'package:ef_steroid/services/dialog/dialog_service.dart';
import 'package:ef_steroid/services/log/log_service.dart';
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
