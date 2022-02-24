import 'package:bot_toast/bot_toast.dart';
import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/domain/migration_history.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/repository/repository.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef6/dotnet_ef6_service.dart';
import 'package:ef_steroid/services/dotnet_ef/model/db_context.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view_model_base.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Ef6OperationViewModel extends EfOperationViewModelBase {
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();
  final DotnetEf6Service _dotnetEf6Service;

  Ef6OperationViewModel(
    this._dotnetEf6Service,
  );

  Future<void> updateConfigFile() async {
    final l = AL.of(context).text;
    final filePickerResult = await FilePicker.platform.pickFiles(
      dialogTitle: l('SelectConfigFile'),
      lockParentWindow: true,
      allowMultiple: false,
      allowedExtensions: [
        'config',
        'json',
      ],
    );

    if (filePickerResult == null) {
      logService.info('User cancels the picker.');
      return;
    }

    final configFilePath = filePickerResult.paths.first;
    if (configFilePath == null) {
      logService.warning('filePickerResult returned null.');
      return;
    }

    final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
    await _efPanelRepository.insertOrUpdateAsync(
      efPanel.copyWith(
        configFileUri: Uri.file(configFilePath),
      ),
    );

    return efPanelRepositoryCache.delete(id: efPanelId);
  }

  @override
  Future<void> listMigrationsAsync() async {
    final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
    final configFileUri = efPanel.configFileUri;
    if (isBusy || configFileUri == null) return;

    notifyListeners(isBusy: true);
    try {
      migrationHistories = await _dotnetEf6Service.listMigrationsAsync(
        projectUri: efPanel.directoryUri,
        configUri: configFileUri,
      );

      sortMigrationHistory();

      showListMigrationBanner = false;
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

  @override
  Future<void> removeMigrationAsync({
    required bool force,
    required MigrationHistory migrationHistory,
  }) async {
    final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
    final configFileUri = efPanel.configFileUri;
    if (isBusy || configFileUri == null) return;
    notifyListeners(isBusy: true);
    try {
      await _dotnetEf6Service.removeMigrationAsync(
        projectUri: efPanel.directoryUri,
        migrationHistory: migrationHistory,
      );
    } catch (ex, stackTrace) {
      logService.severe(ex, stackTrace);
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
    } finally {
      notifyListeners(isBusy: false);
    }
  }

  @override
  Future<void> updateDatabaseToTargetedMigrationAsync({
    required MigrationHistory migrationHistory,
  }) async {
    try {
      final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
      final configFileUri = efPanel.configFileUri;
      if (isBusy || configFileUri == null) return;

      notifyListeners(isBusy: true);
      await _dotnetEf6Service.updateDatabaseAsync(
        projectUri: efPanel.directoryUri,
        migrationHistory: migrationHistory,
        configUri: configFileUri,
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

  @override
  Future<void> addMigrationAsync() async {
    try {
      final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
      final configFileUri = efPanel.configFileUri;
      if (configFileUri == null) return;

      checkInput();

      await _dotnetEf6Service.addMigrationAsync(
        projectUri: efPanel.directoryUri,
        migrationName: form.migrationFormField.toText(),
        configUri: configFileUri,
        force: form.forceFormField.valueNotifier.value,
        ignoreChanges: form.ignoreChangesFormField.valueNotifier.value,
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

  @override
  bool canShowRemoveMigrationButton({
    required MigrationHistory migrationHistory,
  }) {
    return true;
  }

  @override
  Future<void> configureDbContextAsync({DbContext? dbContext}) {
    return Future.value();
  }

  @override
  Future<void> fetchDbContextsAsync() {
    return Future.value();
  }
}
