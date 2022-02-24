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
import 'package:ef_steroid/repository_cache/repository_cache.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_migration/dotnet_ef_migration_service.dart';
import 'package:ef_steroid/shared/project_ef_type.dart';
import 'package:ef_steroid/util/message_key.dart';
import 'package:ef_steroid/util/messaging_center.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view_model_data.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/mixins/db_context_selector_view_model_mixin.dart';
import 'package:ef_steroid/views/ef_panel/tab_data_value.dart';
import 'package:ef_steroid/views/root_tab_view.dart';
import 'package:ef_steroid/views/view_model_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:quiver/strings.dart';

abstract class EfOperationViewModelBase extends ViewModelBase
    with
        FormViewModelMixin<_AddMigrationFormModel>,
        DbContextSelectorViewModelMixin {
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();
  @protected
  final RepositoryCache<EfPanel> efPanelRepositoryCache =
      GetIt.I<RepositoryCache<EfPanel>>();
  final DotnetEfMigrationService _dotnetEfMigrationService =
      GetIt.I<DotnetEfMigrationService>();

  late final int _efPanelId;

  int get efPanelId => _efPanelId;

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

  bool _sortMigrationByAscending = false;

  /// Indicate if we should sort the migration column in ascending order.
  @nonVirtual
  bool get sortMigrationByAscending => _sortMigrationByAscending;

  @nonVirtual
  set sortMigrationByAscending(bool sortMigrationByAscending) {
    if (sortMigrationByAscending == _sortMigrationByAscending) return;
    _sortMigrationByAscending = sortMigrationByAscending;
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
      _efPanelId = state.efPanelId;
    }

    await _setupMigrationFilesWatchers();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _rootTabView = context.findAncestorWidgetOfExactType<RootTabView>()!;
      // Run migration listing when this is the selected tab.
      if (isSelectedTab()) {
        await _loadViewInitially();
      }
      // Schedule the migration listing until user selects the tab.
      else {
        _rootTabView.tabbedViewController.addListener(_onTabChangedAsync);
      }
    });
    return super.initViewModelAsync(initParam: initParam);
  }

  /// Check if [this] is the selected tab.
  @nonVirtual
  bool isSelectedTab() {
    final selectedTab = _rootTabView.tabbedViewController.selectedTab;
    return selectedTab != null &&
        (selectedTab.value as EfPanelTabDataValue).efPanel.id == efPanelId;
  }

  Future<void> _onTabChangedAsync() async {
    if (!isSelectedTab()) {
      return;
    }

    _rootTabView.tabbedViewController.removeListener(_onTabChangedAsync);
    await _loadViewInitially();
  }

  Future<void> _loadViewInitially() async {
    final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
    final dbContextName = efPanel.dbContextName;

    if (isNotBlank(dbContextName)) {
      await listMigrationsAsync();
    }
    await fetchDbContextsAsync();
    await configureDbContextAsync();
    if (isBlank(dbContextName)) {
      await listMigrationsAsync();
    }
  }

  Future<Directory> _getMigrationsDirectory() async {
    final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
    return Directory.fromUri(
      _dotnetEfMigrationService.getMigrationsDirectory(
        projectUri: efPanel.directoryUri,
      ),
    );
  }

  /// If the directory changes, there is a possible migration changes.
  Future<void> _setupMigrationFilesWatchers() async {
    if (_migrationFileSubscription != null) {
      throw StateError('You can only call _setupMigrationFilesWatchers once.');
    }

    _migrationFileSubscription = (await _getMigrationsDirectory())
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
    migrationHistories = sortMigrationByAscending
        ? migrationHistories.orderBy((x) => x.id).toList(growable: false)
        : migrationHistories
            .orderByDescending((x) => x.id)
            .toList(growable: false);
  }

  Future<void> switchEfProjectTypeAsync({
    required ProjectEfType efProjectType,
  }) async {
    await _storeEfProjectTypeAsync(efProjectType: efProjectType);
    MessagingCenter.send(
      MessageKey.onEfProjectTypeChanged,
      this,
    );
    await listMigrationsAsync();
  }

  Future<void> _storeEfProjectTypeAsync({
    required ProjectEfType efProjectType,
  }) async {
    final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
    if (efPanel.projectEfType == efProjectType) return;

    if (isBusy) return;
    notifyListeners(isBusy: true);

    try {
      await _efPanelRepository.insertOrUpdateAsync(
        efPanel.copyWith(
          projectEfType: efProjectType,
        ),
      );
      efPanelRepositoryCache.delete(id: efPanelId);
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
