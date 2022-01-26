import 'dart:async';
import 'dart:io';

import 'package:darq/darq.dart';
import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/domain/migration_history.dart';
import 'package:ef_steroid/helpers/tabbed_view_controller_helper.dart';
import 'package:ef_steroid/models/form/form_model.dart';
import 'package:ef_steroid/models/form/form_view_model_mixin.dart';
import 'package:ef_steroid/models/form/single_value_form_field_model.dart';
import 'package:ef_steroid/models/form/text_editing_form_field_model.dart';
import 'package:ef_steroid/repository/repository.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_migration/dotnet_ef_migration_service.dart';
import 'package:ef_steroid/shared/project_ef_type.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view_model_data.dart';
import 'package:ef_steroid/views/ef_panel/ef_project_operation/ef_project_operation_view.dart';
import 'package:ef_steroid/views/ef_panel/tab_data_value.dart';
import 'package:ef_steroid/views/root_tab_view.dart';
import 'package:ef_steroid/views/view_model_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

abstract class EfOperationViewModelBase extends ViewModelBase
    with FormViewModelMixin<_AddMigrationFormModel> {
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();
  final DotnetEfMigrationService _dotnetEfMigrationService =
      GetIt.I<DotnetEfMigrationService>();

  late EfPanel _efPanel;

  @nonVirtual
  EfPanel get efPanel => _efPanel;

  @override
  final _AddMigrationFormModel form = _AddMigrationFormModel();
  bool _showListMigrationBanner = false;

  /// Indicate if we should show the list migration banner to inform the user
  /// that we might need to run [listMigrationsAsync].
  @nonVirtual
  bool get showListMigrationBanner => _showListMigrationBanner;

  @protected
  @nonVirtual
  set showListMigrationBanner(bool value) => _showListMigrationBanner = value;

  List<MigrationHistory> _migrationHistories = [];

  /// The migration histories.
  @nonVirtual
  List<MigrationHistory> get migrationHistories => _migrationHistories;

  @nonVirtual
  @protected
  set migrationHistories(List<MigrationHistory> value) =>
      _migrationHistories = value;

  bool _sortMigrationAscending = true;

  /// Indicate if we should sort the migration column in ascending order.
  @nonVirtual
  bool get sortMigrationAscending => _sortMigrationAscending;

  @nonVirtual
  set sortMigrationAscending(bool sortMigrationAscending) {
    if (sortMigrationAscending == _sortMigrationAscending) return;
    _sortMigrationAscending = sortMigrationAscending;
    sortMigrationHistory();
    notifyListeners();
  }

  late RootTabView _rootTabView;

  StreamSubscription<FileSystemEvent>? _migrationFileSubscription;

  @override
  Future<void> initViewModelAsync({
    required InitParam initParam,
  }) async {
    final state = initParam.param;
    if (state is EfOperationViewModelData) {
      updateEfPanel(state.efPanel);
    }

    _setupMigrationFilesWatchers();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _rootTabView = context.findAncestorWidgetOfExactType<RootTabView>()!;
      // Run migration listing when this is the selected tab.
      if (isSelectedTab()) {
        await listMigrationsAsync();
      }
      // Schedule the migration listing until user selects the tab.
      else {
        _rootTabView.tabbedViewController.addListener(_onTabChangedAsync);
      }
    });
    return super.initViewModelAsync(initParam: initParam);
  }

  void updateEfPanel(EfPanel efPanel) {
    _efPanel = efPanel;
  }

  /// Check if [this] is the selected tab.
  @nonVirtual
  bool isSelectedTab() {
    final selectedTab = _rootTabView.tabbedViewController.selectedTab;
    return selectedTab != null &&
        (selectedTab.value as EfPanelTabDataValue).efPanel.id == efPanel.id;
  }

  Future<void> _onTabChangedAsync() async {
    if (!isSelectedTab()) {
      return;
    }

    _rootTabView.tabbedViewController.removeListener(_onTabChangedAsync);
    await listMigrationsAsync();
  }

  Directory _getMigrationsDirectory() {
    return Directory.fromUri(
      _dotnetEfMigrationService.getMigrationsDirectory(
        projectUri: efPanel.directoryUri,
      ),
    );
  }

  /// If the directory changes, there is a possible migration changes.
  void _setupMigrationFilesWatchers() {
    if (_migrationFileSubscription != null) {
      throw StateError('You can only call _setupMigrationFilesWatchers once.');
    }

    _migrationFileSubscription = _getMigrationsDirectory()
        .watch()
        .listen(onNewMigrationsAddedToDirectory);
  }

  @protected
  void onNewMigrationsAddedToDirectory(FileSystemEvent event) {
    if (!isSelectedTab()) return;

    if (_showListMigrationBanner) return;

    _showListMigrationBanner = true;
    notifyListeners();
  }

  void hideListMigrationBanner() {
    _showListMigrationBanner = false;
    notifyListeners();
  }

  Future<void> listMigrationsAsync();

  /// Remove a migration.
  ///
  /// - For EFCore, this will remove the latest migration regardless the provided
  /// [migrationHistory].
  /// - For EF6, this will remove the [migrationHistory] and omits [force].
  Future<void> removeMigrationAsync({
    required bool force,
    required MigrationHistory migrationHistory,
  });

  @nonVirtual
  Future<void> revertAllMigrationsAsync() =>
      updateDatabaseToTargetedMigrationAsync(
        migrationHistory: const MigrationHistory.ancient(),
      );

  Future<void> addMigrationAsync();

  Future<void> updateDatabaseToTargetedMigrationAsync({
    required MigrationHistory migrationHistory,
  });

  @protected
  @nonVirtual
  void sortMigrationHistory() {
    migrationHistories = sortMigrationAscending
        ? migrationHistories.orderBy((x) => x.id).toList(growable: false)
        : migrationHistories
            .orderByDescending((x) => x.id)
            .toList(growable: false);
  }

  Future<void> switchEfProjectTypeAsync({
    required ProjectEfType efProjectType,
  }) async {
    if (efPanel.projectEfType == efProjectType) return;

    if (isBusy) return;
    notifyListeners(isBusy: true);

    try {
      await _efPanelRepository.insertOrUpdateAsync(
        efPanel.copyWith(
          projectEfType: efProjectType,
        ),
      );
      await EfProjectOperation.of(context)!.refreshEfPanelAsync();
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

  bool canShowRemoveMigrationButton({
    required MigrationHistory migrationHistory,
  });

  @override
  void dispose() {
    _migrationFileSubscription?.cancel();
    super.dispose();
  }
}

class _AddMigrationFormModel extends FormModel {
  final TextEditingFormFieldModel migrationFormField;

  final SingleValueFormFieldModel<bool> forceFormField, ignoreChangesFormField;

  _AddMigrationFormModel()
      : migrationFormField = TextEditingFormFieldModel(),
        forceFormField = SingleValueFormFieldModel.fromValue(
          valueNotifier: ValueNotifier(false),
        ),
        ignoreChangesFormField = SingleValueFormFieldModel.fromValue(
          valueNotifier: ValueNotifier(false),
        );

  @override
  void dispose() {
    migrationFormField.dispose();
    forceFormField.dispose();
    ignoreChangesFormField.dispose();
  }
}
