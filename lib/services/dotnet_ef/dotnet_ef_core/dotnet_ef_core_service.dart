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

import 'package:ef_steroid/domain/migration_history.dart';
import 'package:ef_steroid/services/dotnet_ef/model/db_context.dart';

abstract class DotnetEfCoreService {
  /// Update the database.
  ///
  /// **Arguments:**
  /// - [projectUri] -> The project uri.
  /// - [migrationHistory] -> The targeted migration history. Update to the
  /// latest if this is null.
  /// - [dbContext] -> The database context name.
  Future<String> updateDatabaseAsync({
    required Uri projectUri,
    MigrationHistory? migrationHistory,
    String? dbContextName,
  });

  /// List all the migrations.
  Future<List<MigrationHistory>> listMigrationsAsync({
    required Uri projectUri,
    String? dbContextName,
  });

  /// Add new migration.
  Future<void> addMigrationAsync({
    required Uri projectUri,
    required String migrationName,
    String? dbContextName,
  });

  /// Remove the last migration.
  ///
  /// Note that Dotnet EF supports only removing the last migration.
  ///
  /// **Arguments:**
  /// - [projectUri] -> The project uri.
  /// - [force] -> Force the migration removal even the migration is applied.
  /// - [dbContextName] -> The database context name.
  Future<void> removeMigrationAsync({
    required Uri projectUri,
    required bool force,
    String? dbContextName,
  });

  /// List all the DB contexts.
  ///
  /// **Arguments:**
  /// - [projectUri] -> The project uri.
  Future<List<DbContext>> listDbContextsAsync({
    required Uri projectUri,
  });
}
