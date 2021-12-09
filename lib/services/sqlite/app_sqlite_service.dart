import 'dart:io';

import 'package:fast_dotnet_ef/services/sqlite/initialization_script.dart';
import 'package:fast_dotnet_ef/services/sqlite/migration_scripts.dart';
import 'package:fast_dotnet_ef/services/sqlite/sqlite_service.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_migration/sqflite_migration.dart';

@LazySingleton(as: SqliteService)
class AppSqliteService extends SqliteService {
  late Database _database;

  @override
  Database get database => _database;

  final config = MigrationConfig(
    initializationScript: initializationScript,
    migrationScripts: migrationScripts,
  );

  @override
  Future<void> setupAsync() async {
    final fastDotnetEfDbPath = p.joinAll(
      [
        (await path_provider.getApplicationSupportDirectory()).path,
        'storage',
        'FastDotnetEfSqlite',
        'FastDotnetEf.db',
      ],
    );

    print(fastDotnetEfDbPath);
    if (Platform.isWindows || Platform.isLinux) {
      databaseFactory = databaseFactoryFfi;
      sqfliteFfiInit();
    }
    _database = await openDatabaseWithMigration(
      fastDotnetEfDbPath,
      config,
    );
  }
}
