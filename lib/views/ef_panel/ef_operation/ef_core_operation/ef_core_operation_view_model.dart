import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:fast_dotnet_ef/domain/migration_history.dart';
import 'package:fast_dotnet_ef/exceptions/dotnet_ef_exception.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef_operation_view_model_base.dart';
import 'package:flutter/material.dart';

class EfCoreOperationViewModel extends EfOperationViewModelBase {
  final DotnetEfService _dotnetEfService;

  EfCoreOperationViewModel(
    this._dotnetEfService,
  );

  @override
  Future<void> listMigrationsAsync() async {
    if (isBusy) return;

    notifyListeners(isBusy: true);
    try {
      migrationHistories = await _dotnetEfService.listMigrationsAsync(
        projectUri: efPanel.directoryUri,
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
  Future<void> updateDatabaseToTargetedMigrationAsync({
    required MigrationHistory migrationHistory,
  }) async {
    try {
      if (isBusy) return;

      notifyListeners(isBusy: true);
      await _dotnetEfService.updateDatabaseAsync(
        projectUri: efPanel.directoryUri,
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

  @override
  Future<void> addMigrationAsync() async {
    try {
      checkInput();

      await _dotnetEfService.addMigrationAsync(
        projectUri: efPanel.directoryUri,
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

  @override
  Future<void> removeMigrationAsync({
    required bool force,
  }) async {
    try {
      if (isBusy) return;
      notifyListeners(isBusy: true);

      await _dotnetEfService.removeMigrationAsync(
        projectUri: efPanel.directoryUri,
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

  Future<void> _promptRerunRemoveMigrationWithForceAsync(
    String? errorMessage,
  ) async {
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
