import 'dart:async';
import 'dart:io';

import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/helpers/uri_helper.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/ef_model/migration_history.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';
import 'package:path/path.dart' as p;

class EfDatabaseOperationViewModel extends ViewModelBase {
  final DotnetEfService _dotnetEfService;

  late EfPanel efPanel;

  final List<MigrationFile> _migrationFiles = [];

  List<MigrationFile> get migrationFiles => _migrationFiles;

  final List<MigrationFile> _migratedFiles = [];

  List<MigrationFile> get migratedFiles => _migratedFiles;

  List<MigrationHistory> _migrationHistories = [];

  /// The migration histories.
  List<MigrationHistory> get migrationHistories => _migrationHistories;

  StreamSubscription<FileSystemEvent>? _migrationFileSubscription;

  EfDatabaseOperationViewModel(
    this._dotnetEfService,
  );

  void initViewModel() {
    _setupMigrationFilesWatchers();
    listMigrationsAsync();
  }

  void _setupMigrationFiles() {
    this.migrationFiles.clear();
    final migrationFiles = _getMigrationsDirectory()
        .listSync()
        .where(_filterMigrationFile)
        .map((event) => MigrationFile(
              fileUri: Uri.parse(event.path),
            ))
        .toList();

    this.migrationFiles.addAll(migrationFiles);
    notifyListeners();
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

  bool _filterMigrationFile(FileSystemEntity event) {
    final file = File(event.path);
    final fileSystemInfo = file.statSync();
    return fileSystemInfo.type == FileSystemEntityType.file &&
        // Contains 2 logic here:
        //
        // 1. The Migrations directory contains extra files (varies for different EF project)
        // that we don't need.
        // 2. The only unique pattern that we can find is the *.designer.cs file.
        // The migration which we are interested in is the one excluding the designer.cs extension.

        p.extension(event.path, 2).toLowerCase() == '.designer.cs';
  }

  /// If the directory changes, there is a possible migration changes. Load the
  /// latest toi figure it out.
  void _setupMigrationFilesWatchers() {
    if (_migrationFileSubscription != null) {
      throw StateError('_setupMigrationFilesWatchers can only be called once.');
    }

    _migrationFileSubscription =
        _getMigrationsDirectory().watch().listen((event) {
      listMigrationsAsync();
    });
  }

  @override
  void dispose() {
    _migrationFileSubscription?.cancel();
    super.dispose();
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
