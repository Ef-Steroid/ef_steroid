import 'package:fast_dotnet_ef/domain/migration_history.dart';

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
