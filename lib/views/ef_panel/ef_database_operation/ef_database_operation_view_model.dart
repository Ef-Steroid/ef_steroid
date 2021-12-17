import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:darq/darq.dart';
import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/exceptions/dotnet_ef_exception.dart';
import 'package:fast_dotnet_ef/helpers/tabbed_view_controller_helper.dart';
import 'package:fast_dotnet_ef/helpers/uri_helper.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/models/form/form_model.dart';
import 'package:fast_dotnet_ef/models/form/form_view_model_mixin.dart';
import 'package:fast_dotnet_ef/models/form/text_editing_form_field_model.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/ef_model/migration_history.dart';
import 'package:fast_dotnet_ef/views/ef_panel/tab_data_value.dart';
import 'package:fast_dotnet_ef/views/root_tab_view.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class EfDatabaseOperationViewModel extends ViewModelBase
    with FormViewModelMixin<_AddMigrationFormModel> {
  final DotnetEfService _dotnetEfService;

  late EfPanel efPanel;

  bool _showListMigrationBanner = false;

  /// Indicate if we should show the list migration banner to inform the user
  /// that we might need to run [listMigrationsAsync].
  bool get showListMigrationBanner => _showListMigrationBanner;

  List<MigrationHistory> _migrationHistories = [];

  /// The migration histories.
  List<MigrationHistory> get migrationHistories => _migrationHistories;

  late RootTabView _rootTabView;

  bool _sortMigrationAscending = true;

  /// Indicate if we should sort the migration column in ascending order.
  bool get sortMigrationAscending => _sortMigrationAscending;

  set sortMigrationAscending(bool sortMigrationAscending) {
    if (sortMigrationAscending == _sortMigrationAscending) return;
    _sortMigrationAscending = sortMigrationAscending;
    _sortMigrationHistory();
    notifyListeners();
  }

  StreamSubscription<FileSystemEvent>? _migrationFileSubscription;

  @override
  final _AddMigrationFormModel form = _AddMigrationFormModel();

  EfDatabaseOperationViewModel(
    this._dotnetEfService,
  );

  @override
  Future<void> initViewModelAsync() async {
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
    return super.initViewModelAsync();
  }

  /// Check if [this] is the selected tab.
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
    final directoryUri = efPanel.directoryUrl;

    final migrationsDirectoryPath = p.joinAll([
      directoryUri.toDecodedString(),
      // TODO: Support user-defined migrations directory.
      // Default Migrations directory.
      'Migrations',
    ]);
    return Directory(migrationsDirectoryPath);
  }

  /// If the directory changes, there is a possible migration changes.
  void _setupMigrationFilesWatchers() {
    if (_migrationFileSubscription != null) {
      throw StateError('You can only call _setupMigrationFilesWatchers once.');
    }

    _migrationFileSubscription =
        _getMigrationsDirectory().watch().listen((event) {
      if (!isSelectedTab()) return;

      if (_showListMigrationBanner) return;

      _showListMigrationBanner = true;
      notifyListeners();
    });
  }

  Future<void> listMigrationsAsync() async {
    if (isBusy) return;

    notifyListeners(isBusy: true);
    try {
      _migrationHistories = await _dotnetEfService.listMigrationAsync(
        projectUri: efPanel.directoryUrl,
      );

      _showListMigrationBanner = false;
      notifyListeners();
    } catch (ex, stackTrace) {
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
    }

    notifyListeners(isBusy: false);
  }

  void hideListMigrationBanner() {
    _showListMigrationBanner = false;
    notifyListeners();
  }

  Future<void> revertAllMigrationsAsync() =>
      updateDatabaseToTargetedMigrationAsync(
        migrationHistory: const MigrationHistory.ancient(),
      );

  Future<void> updateDatabaseToTargetedMigrationAsync({
    required MigrationHistory migrationHistory,
  }) async {
    try {
      if (isBusy) return;

      notifyListeners(isBusy: true);
      await _dotnetEfService.updateDatabaseAsync(
        projectUri: efPanel.directoryUrl,
        migrationHistory: migrationHistory,
      );

      notifyListeners(isBusy: false);

      BotToast.showText(
        text: AL.of(context).text('DoneUpdatingDatabase'),
      );

      return listMigrationsAsync();
    } catch (ex, stackTrace) {
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
      notifyListeners(isBusy: false);
    }
  }

  void _sortMigrationHistory() {
    _migrationHistories = sortMigrationAscending
        ? migrationHistories.orderBy((x) => x.id).toList(growable: false)
        : migrationHistories
            .orderByDescending((x) => x.id)
            .toList(growable: false);
  }

  Future<void> addMigrationAsync() async {
    try {
      checkInput();

      await _dotnetEfService.addMigrationAsync(
        projectUri: efPanel.directoryUrl,
        migrationName: form.migrationFormField.toText(),
      );

      Navigator.pop(context);
    } catch (ex, stackTrace) {
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
    }
  }

  Future<void> removeMigrationAsync({
    required bool force,
  }) async {
    try {
      if (isBusy) return;
      notifyListeners(isBusy: true);

      await _dotnetEfService.removeMigrationAsync(
        projectUri: efPanel.directoryUrl,
        force: force,
      );

      notifyListeners(isBusy: false);

      BotToast.showText(
        text: AL.of(context).text('DoneRemovingMigration'),
      );

      return listMigrationsAsync();
    } catch (ex, stackTrace) {
      if (ex is RemoveMigrationDotnetEfException &&
          ex.isMigrationAppliedError) {
        notifyListeners(isBusy: false);
        return _promptRerunRemoveMigrationWithForceAsync(ex.errorMessage);
      }
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
      notifyListeners(isBusy: false);
    }
  }

  Future<void> _promptRerunRemoveMigrationWithForceAsync(String? errorMessage) async {
    final l = AL.of(context).text;
    final response = await dialogService.promptConfirmationDialog(
      context,
      title: l('DoYouWantToRerunWithForce'),
      subtitle: errorMessage,
      okText: l('Yes'),
      cancelText: l('No'),
    );

    if (response == true) {
      return removeMigrationAsync(force: true);
    }
  }
}

class _AddMigrationFormModel extends FormModel {
  final TextEditingFormFieldModel migrationFormField;

  _AddMigrationFormModel() : migrationFormField = TextEditingFormFieldModel();

  @override
  void dispose() {
    migrationFormField.dispose();
  }
}
