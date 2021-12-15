import 'dart:async';

import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/helpers/tabbed_view_controller_helper.dart';
import 'package:fast_dotnet_ef/helpers/uri_helper.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/ef_model/migration_history.dart';
import 'package:fast_dotnet_ef/views/ef_panel/tab_data_value.dart';
import 'package:fast_dotnet_ef/views/root_tab_view.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class EfDatabaseOperationViewModel extends ViewModelBase {
  final DotnetEfService _dotnetEfService;

  late EfPanel efPanel;

  List<MigrationHistory> _migrationHistories = [];

  /// The migration histories.
  List<MigrationHistory> get migrationHistories => _migrationHistories;

  late RootTabView _rootTabView;

  EfDatabaseOperationViewModel(
    this._dotnetEfService,
  );

  @override
  Future<void> initViewModelAsync() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _rootTabView = context.findAncestorWidgetOfExactType<RootTabView>()!;
      final selectedTab = _rootTabView.tabbedViewController.selectedTab;
      // Run migration listing when this is the selected tab.
      if (selectedTab == null ||
          (selectedTab.value as EfPanelTabDataValue).efPanel.id == efPanel.id) {
        await listMigrationsAsync();
      }
      // Schedule the migration listing until user selects the tab.
      else {
        _rootTabView.tabbedViewController.addListener(_onTabChangedAsync);
      }
    });
    return super.initViewModelAsync();
  }

  Future<void> _onTabChangedAsync() async {
    final selectedTab = _rootTabView.tabbedViewController.selectedTab;
    if (selectedTab == null ||
        (selectedTab.value as EfPanelTabDataValue).efPanel.id != efPanel.id) {
      return;
    }

    _rootTabView.tabbedViewController.removeListener(_onTabChangedAsync);
    await listMigrationsAsync();
  }

  Future<void> listMigrationsAsync() async {
    if (isBusy) return;

    isBusy = true;
    try {
      _migrationHistories = await _dotnetEfService.listMigrationAsync(
        projectUri: efPanel.directoryUrl,
      );
    } catch (ex, stackTrace) {
      //TODO: Pop a dialog.
      logService.severe(
        'Unable to list migrations.',
        ex,
        stackTrace,
      );
    }

    isBusy = false;
  }
}

class MigrationFile {
  final Uri fileUri;

  /// The migration file name.
  late final String fileName;

  MigrationFile({
    required Uri fileUri,
  }) : fileUri = Uri.parse(p.setExtension(
          p.withoutExtension(fileUri.toDecodedString()),
          '.cs',
        )) {
    fileName = p.basenameWithoutExtension(this.fileUri.toDecodedString());
  }
}
