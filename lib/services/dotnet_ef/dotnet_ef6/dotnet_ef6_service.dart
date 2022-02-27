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

abstract class DotnetEf6Service {
  /// List all the migrations.
  ///
  /// **Arguments:**
  ///
  /// {@template dotnet_ef6_service.DotnetEf6Service.listMigrationsAsync}
  ///
  /// - [projectUri] -> The EntityFramework project uri.
  /// - [configUri] -> The config file uri.
  ///
  /// {@endtemplate}
  Future<List<MigrationHistory>> listMigrationsAsync({
    required Uri projectUri,
    required Uri configUri,
  });

  /// Update the database.
  ///
  /// **Arguments:**
  ///
  /// {@macro dotnet_ef6_service.DotnetEf6Service.listMigrationsAsync}
  /// - [migrationHistory] -> The targeted migration history. Update to the
  /// latest if this is null.
  Future<String> updateDatabaseAsync({
    required Uri projectUri,
    required Uri configUri,
    MigrationHistory? migrationHistory,
  });

  /// Add new migration.
  /// **Arguments:**
  ///
  /// {@macro dotnet_ef6_service.DotnetEf6Service.listMigrationsAsync}
  /// - [migrationName] -> The migration to add.
  Future<void> addMigrationAsync({
    required Uri projectUri,
    required Uri configUri,
    required String migrationName,
    required bool force,
    required bool ignoreChanges,
  });

  /// Get a list of migrations from 'Migrations' directory.
  List<String> getLocalMigrations({
    required Uri projectUri,
  });

  /// Remove the selected migration.
  ///
  /// **Arguments:**
  /// - [projectUri] -> The project uri.
  /// - [migrationHistory] -> The migration history to remove.
  Future<void> removeMigrationAsync({
    required Uri projectUri,
    required MigrationHistory migrationHistory,
  });
}
