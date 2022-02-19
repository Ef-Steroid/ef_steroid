import 'dart:async';

import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/repository/repository.dart';
import 'package:ef_steroid/services/cs_project_resolver/cs_project_resolver.dart';
import 'package:ef_steroid/shared/project_ef_type.dart';
import 'package:ef_steroid/views/ef_panel/ef_project_operation/ef_project_operation_view_model_data.dart';
import 'package:ef_steroid/views/view_model_base.dart';
import 'package:get_it/get_it.dart';

class EfProjectOperationViewModel extends ViewModelBase {
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();
  final CsProjectResolver _csProjectResolver;

  /// A completer for [_detectProjectTypeAsync].
  final Completer<void> projectTypeDetectionCompleter = Completer<void>();

  late int _efPanelId;

  EfPanel? _efPanel;

  EfPanel? get efPanel => _efPanel;

  EfProjectOperationViewModel(
    this._csProjectResolver,
  );

  @override
  Future<void> initViewModelAsync({
    required InitParam initParam,
  }) async {
    final state = initParam.param;
    if (state is EfProjectOperationViewModelData) {
      _efPanelId = state.efPanelId;
      await fetchEfPanelAsync();
      await _detectProjectTypeAsync();
      projectTypeDetectionCompleter.complete();
      return super.initViewModelAsync(initParam: initParam);
    }
    throw StateError('Incorrect state type.');
  }

  Future<void> fetchEfPanelAsync() async {
    final efPanelId = _efPanelId;

    if (isBusy) return;
    notifyListeners(isBusy: true);

    try {
      _efPanel = await _efPanelRepository.getAsync(efPanelId);
    } catch (ex, stackTrace) {
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
      logService.severe(ex, stackTrace);
    } finally {
      notifyListeners(isBusy: false);
    }
  }

  Future<void> switchEfProjectTypeAsync({
    required ProjectEfType projectEfType,
  }) async {
    final efPanel = this.efPanel!;
    if (efPanel.projectEfType == projectEfType) return;

    if (isBusy) return;
    notifyListeners(isBusy: true);

    try {
      await _efPanelRepository.insertOrUpdateAsync(
        efPanel.copyWith(
          projectEfType: projectEfType,
        ),
      );
      await fetchEfPanelAsync();
    } catch (ex, stackTrace) {
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
      logService.severe(ex, stackTrace);
    } finally {
      notifyListeners(isBusy: false);
    }
  }

  /// Detect the [ProjectEfType] of a [EfPanel].
  ///
  /// We call this method only in the initialization of this view model.
  ///
  /// This method detects the [ProjectEfType] only when [EfPanel.projectEfType]
  /// is null.
  Future<void> _detectProjectTypeAsync() async {
    try {
      var efPanel = this.efPanel;
      if (efPanel == null) {
        throw StateError('EfPanel is not initialized.');
      }

      if (efPanel.projectEfType != null &&
          // Allow ProjectEfType.defaultValue so that in the future when we
          // support it, we are able to detect it.
          efPanel.projectEfType != ProjectEfType.defaultValue) return;

      final projectUri = efPanel.directoryUri;
      final csProjectAsset =
          await _csProjectResolver.getCsProjectAsset(projectUri: projectUri);

      final ef6PackageRegex = RegExp(r'^EntityFramework/6.+');
      final efCorePackageRegex = RegExp(r'^Microsoft.EntityFrameworkCore/.+');

      ProjectEfType? projectEfType;
      csProjectAsset.libraries.forEach((key, value) {
        if (ef6PackageRegex.hasMatch(key)) {
          projectEfType = ProjectEfType.ef6;
          return;
        }

        if (efCorePackageRegex.hasMatch(key)) {
          projectEfType = ProjectEfType.efCore;
          return;
        }
      });

      if (projectEfType == null) {
        return;
      }

      _efPanel = efPanel = efPanel.copyWith(
        projectEfType: projectEfType,
      );

      await _efPanelRepository.insertOrUpdateAsync(efPanel);
    } catch (ex, stackTrace) {
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
      logService.severe(ex, stackTrace);
    }
  }
}
