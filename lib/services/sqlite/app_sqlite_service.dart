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

import 'dart:io';

import 'package:ef_steroid/services/file/resource_group_key.dart';
import 'package:ef_steroid/services/file/resource_key.dart';
import 'package:ef_steroid/services/log/log_service.dart';
import 'package:ef_steroid/services/sqlite/initialization_script.dart';
import 'package:ef_steroid/services/sqlite/migration_scripts.dart';
import 'package:ef_steroid/services/sqlite/sqlite_service.dart';
import 'package:ef_steroid/services/sqlite/unit_of_work.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_migration/sqflite_migration.dart';
import 'package:synchronized/synchronized.dart';

@LazySingleton(as: SqliteService)
class AppSqliteService extends SqliteService {
  final LogService _logService;

  String? _dbPath;

  @override
  String get dbPath => _dbPath ??= throw StateError(
        'Unable to locate the database. Did you call SqliteService.setupAsync?',
      );

  final Lock _useDatabaseLock = Lock();

  AppSqliteService(
    this._logService,
  );

  final config = MigrationConfig(
    initializationScript: initializationScript,
    migrationScripts: migrationScripts,
  );

  @override
  Future<void> setupAsync() async {
    final fastDotnetEfDbPath = p.joinAll(
      [
        (await path_provider.getApplicationSupportDirectory()).path,
        ResourceGroupKey.storage,
        ResourceGroupKey.efSteroidSqlite,
        ResourceKey.efSteroid,
      ],
    );

    _dbPath = fastDotnetEfDbPath;

    _logService.info(fastDotnetEfDbPath);

    if (Platform.isWindows || Platform.isLinux) {
      databaseFactory = databaseFactoryFfi;
      sqfliteFfiInit();
    }
    final database = await openDatabaseWithMigration(
      fastDotnetEfDbPath,
      config,
    );
    _logService.info('Done database migration');

    return database.close();
  }

  @override
  Future<T> useDatabaseAsync<T>({
    required UnitOfWork<T> uow,
    required DefaultResultAction<T> orDefault,
  }) {
    return _useDatabaseCoreAsync(
      uow: uow,
      readonly: false,
      orDefault: orDefault,
    );
  }

  @override
  Future<T> useReadonlyDatabaseAsync<T>({
    required UnitOfWork<T> uow,
    required DefaultResultAction<T> orDefault,
  }) {
    return _useDatabaseCoreAsync(
      uow: uow,
      readonly: true,
      orDefault: orDefault,
    );
  }

  Future<T> _useDatabaseCoreAsync<T>({
    required UnitOfWork<T> uow,
    required bool readonly,
    required DefaultResultAction<T> orDefault,
  }) {
    return _useDatabaseLock.synchronized(() async {
      _logService.info('Start opening database');
      final database = await openDatabase(dbPath);

      T result;
      try {
        _logService.info('Start unit of work');
        result = await uow(database);
      } catch (ex, stackTrace) {
        _logService.severe(
          'Unable to run unit of work',
          ex,
          stackTrace,
        );

        result = orDefault();
      }

      _logService.info('Start closing database');
      await database.close();
      _logService.info('Done closing database');
      return result;
    });
  }
}
