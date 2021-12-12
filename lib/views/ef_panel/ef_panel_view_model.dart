import 'package:darq/darq.dart';
import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/mixins/expansion_panel_item_mixin.dart';
import 'package:fast_dotnet_ef/repository/repository.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel_view.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class EfPanelViewModel extends ViewModelBase {
  final DotnetEfService _dotnetEfService;
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();
  final LogService _logService;

  final Map<EfOperation, EfOperationModel> efOperations = EfOperation.values
      .map((e) => EfOperationModel(efOperation: e))
      .toMap((element) => MapEntry(element.efOperation, element));

  late EfPanel efPanel;

  EfPanelViewModel(
    this._dotnetEfService,
    this._logService,
  );

  Future<void> updateDatabaseAsync() async {
    if (isBusy) return;
    isBusy = true;
    await _dotnetEfService.updateDatabaseAsync(
      projectUri: context
          .findAncestorWidgetOfExactType<EfPanelView>()!
          .efPanel
          .directoryUrl,
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

  Future<void> initViewModelAsync() {
    return _loadIsExpandedAsync();
  }

  void setIsExpanded({
    required int index,
    required bool isExpanded,
  }) async {
    efOperations[EfOperation.values[index]]!.isExpanded = isExpanded;
    _storeIsExpandedAsync(isExpanded: isExpanded);
  }

  void _storeIsExpandedAsync({
    required bool isExpanded,
  }) {
    _efPanelRepository.insertOrUpdateAsync(efPanel.copyWith(
      isUpdateDatabaseSectionExpanded: isExpanded,
    ));
  }

  Future<void> _loadIsExpandedAsync() async {
    efPanel = await _efPanelRepository
        .getAsync(efPanel.id!)
        .then((value) => value ?? efPanel);

    efOperations[EfOperation.database]!.isExpanded =
        efPanel.isUpdateDatabaseSectionExpanded;
    notifyListeners();
  }
}

class EfOperationModel with ExpansionPanelItemMixin {
  final EfOperation efOperation;

  EfOperationModel({
    required this.efOperation,
  });
}
