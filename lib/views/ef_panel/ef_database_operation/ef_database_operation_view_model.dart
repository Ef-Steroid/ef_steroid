import 'dart:async';
import 'dart:io';

import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/helpers/uri_helper.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';
import 'package:path/path.dart' as p;

class EfDatabaseOperationViewModel extends ViewModelBase {
  late EfPanel efPanel;

  final List<MigrationFile> _migrationFiles = [];

  List<MigrationFile> get migrationFiles => _migrationFiles;

  StreamSubscription<FileSystemEvent>? _migrationFileSubscription;

  EfDatabaseOperationViewModel();

  void initViewModel() {
    _setupMigrationFiles();
    _setupMigrationFilesWatchers();
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

  void _setupMigrationFilesWatchers() {
    if (_migrationFileSubscription != null) {
      throw StateError('_setupMigrationFilesWatchers can only be called once.');
    }

    _migrationFileSubscription =
        _getMigrationsDirectory().watch().listen((event) {
      _setupMigrationFiles();
    });
  }

  bool _filterMigrationFile(FileSystemEntity event) {
    final file = File(event.path);
    final fileSystemInfo = file.statSync();
    return fileSystemInfo.type == FileSystemEntityType.file &&
        p.extension(event.path) == '.cs';
  }

  @override
  void dispose() {
    _migrationFileSubscription?.cancel();
    super.dispose();
  }
}

class MigrationFile {
  final Uri fileUri;

  MigrationFile({
    required this.fileUri,
  });
}
