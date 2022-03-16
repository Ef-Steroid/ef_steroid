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

    final efPanel = await fetchEfPanelAsync();
    await _efPanelRepository.insertOrUpdateAsync(
      efPanel.copyWith(
        configFileUri: Uri.file(configFilePath),
      ),
    );

    return efPanelRepositoryCache.delete(id: efPanelId);
  }

  @override
  Future<void> listMigrationsAsync({
    bool omitMultipleContextsError = false,
  }) async {
    final efPanel = await fetchEfPanelAsync();
    final configFileUri = efPanel.configFileUri;
    if (isBusy || configFileUri == null) return;

    notifyListeners(isBusy: true);
    try {
      dbContextMigrationHistoriesMap[const DbContext.dummy()] =
          await _dotnetEf6Service.listMigrationsAsync(
        projectUri: efPanel.directoryUri,
        configUri: configFileUri,
      );

      await sortMigrationHistoryAsync();

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
    final efPanel = await fetchEfPanelAsync();
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
      final efPanel = await fetchEfPanelAsync();
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
      final efPanel = await fetchEfPanelAsync();
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
    required DbContext dbContext,
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
