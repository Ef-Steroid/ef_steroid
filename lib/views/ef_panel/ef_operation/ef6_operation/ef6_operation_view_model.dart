import 'package:bot_toast/bot_toast.dart';
import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/domain/migration_history.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/repository/repository.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef6/dotnet_ef6_service.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef_operation_view_model_base.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_project_operation/ef_project_operation_view.dart';
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

    await _efPanelRepository.insertOrUpdateAsync(
      efPanel.copyWith(
        configFileUri: Uri.file(configFilePath),
      ),
    );

    return EfProjectOperation.of(context)!.refreshEfPanelAsync();
  }

  @override
  Future<void> listMigrationsAsync() async {
    final configFileUri = efPanel.configFileUri;
    if (isBusy || configFileUri == null) return;

    notifyListeners(isBusy: true);
    try {
      migrationHistories = await _dotnetEf6Service.listMigrationsAsync(
        projectUri: efPanel.directoryUri,
        configUri: configFileUri,
      );

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
  }) {
    // TODO: implement removeMigrationAsync
    throw UnimplementedError();
  }

  @override
  Future<void> updateDatabaseToTargetedMigrationAsync({
    required MigrationHistory migrationHistory,
  }) async {
    try {
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
      final configFileUri = efPanel.configFileUri;
      if (configFileUri == null) return;

      checkInput();

      await _dotnetEf6Service.addMigrationAsync(
        projectUri: efPanel.directoryUri,
        migrationName: form.migrationFormField.toText(),
        configUri: configFileUri,
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
}
