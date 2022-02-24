import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/domain/migration_history.dart';
import 'package:ef_steroid/exceptions/dotnet_ef_exception.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/repository/repository.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_core/dotnet_ef_core_service.dart';
import 'package:ef_steroid/services/dotnet_ef/model/db_context.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view_model_base.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class EfCoreOperationViewModel extends EfOperationViewModelBase {
  final DotnetEfCoreService _dotnetEfService;
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();

  EfCoreOperationViewModel(
    this._dotnetEfService,
  );

  @override
  Future<void> listMigrationsAsync() async {
    if (isBusy) return;

    notifyListeners(isBusy: true);
    try {
      final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
      migrationHistories = await _dotnetEfService.listMigrationsAsync(
        projectUri: efPanel.directoryUri,
        dbContextName: efPanel.dbContextName,
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
  Future<void> updateDatabaseToTargetedMigrationAsync({
    required MigrationHistory migrationHistory,
  }) async {
    try {
      if (isBusy) return;

      notifyListeners(isBusy: true);
      final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
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

      final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
      await _dotnetEfService.addMigrationAsync(
        projectUri: efPanel.directoryUri,
        migrationName: form.migrationFormField.toText(),
        dbContextName: efPanel.dbContextName,
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
    required MigrationHistory migrationHistory,
  }) async {
    try {
      if (isBusy) return;
      notifyListeners(isBusy: true);

      final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
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
        return _promptRerunRemoveMigrationWithForceAsync(
          errorMessage: ex.errorMessage,
          migrationHistory: migrationHistory,
        );
      }
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
      notifyListeners(isBusy: false);
    }
  }

  @override
  Future<void> fetchDbContextsAsync() async {
    try {
      final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
      dbContexts = await _dotnetEfService.listDbContextsAsync(
        projectUri: efPanel.directoryUri,
      );
    } catch (ex, stackTrace) {
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
    }
  }

  @override
  Future<void> configureDbContextAsync({
    DbContext? dbContext,
  }) async {
    try {
      final dbContexts = this.dbContexts;
      if (dbContexts.isEmpty) {
        throw Exception(AL.of(context).text('NoDbContextFound'));
      }

      final efPanel = await efPanelRepositoryCache.getAsync(id: efPanelId);
      var dbContextName = (dbContext?.safeName ?? efPanel.dbContextName);
      dbContextName ??= dbContexts.first.safeName;

      logService.info('Using dbContextName: $dbContextName');

      await _efPanelRepository.insertOrUpdateAsync(
        efPanel.copyWith(
          dbContextName: dbContextName,
        ),
      );

      efPanelRepositoryCache.delete(id: efPanelId);
      notifyListeners();
    } catch (ex, stackTrace) {
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
    }
  }

  Future<void> _promptRerunRemoveMigrationWithForceAsync({
    String? errorMessage,
    required MigrationHistory migrationHistory,
  }) async {
    final l = AL.of(context).text;
    final response = await dialogService.promptConfirmationDialog(
      context,
      title: l('DoYouWantToRerunWithForce'),
      subtitle: errorMessage,
      okText: l('Yes'),
      cancelText: l('No'),
    );

    if (response == true) {
      return removeMigrationAsync(
        force: true,
        migrationHistory: migrationHistory,
      );
    }
  }

  @override
  bool canShowRemoveMigrationButton({
    required MigrationHistory migrationHistory,
  }) {
    return (sortMigrationByAscending
            ? migrationHistories.last.id
            : migrationHistories.first.id) ==
        migrationHistory.id;
  }
}
