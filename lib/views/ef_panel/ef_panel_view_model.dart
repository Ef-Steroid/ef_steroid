import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel_view.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';
import 'package:flutter/foundation.dart';

class EfPanelViewModel extends ViewModelBase {
  final DotnetEfService _dotnetEfService;
  final LogService _logService;

  EfPanelViewModel(
    this._dotnetEfService,
    this._logService,
  );

  Future<void> updateDatabaseAsync() async {
    if (isBusy) return;
    isBusy = true;
    await _dotnetEfService.updateDatabaseAsync(
      projectUri: context.findAncestorWidgetOfExactType<EfPanelView>()!.fileUri,
    );

    isBusy = false;
  }

  Future<void> collectLogAsync() async {
    final log = _logService.getLog();
    if (kDebugMode) {
      for (final e in log) {
        print('[${e.level}] ${e.loggerName}: ${e.message}\n ${e.error}');
      }
    }
  }
}
