import 'package:fast_dotnet_ef/services/dotnet_ef/ef_model/migration_history.dart';

abstract class DotnetEf6Service {
  /// List all the migrations.
  ///
  /// **Arguments:**
  ///
  /// {@template dotnet_ef6_service.DotnetEf6Service.listMigrationsAsync}
  ///
  /// - [csprojUri] -> The EntityFramework project uri.
  /// - [configUri] -> The config file uri.
  ///
  /// {@endtemplate}
  Future<List<String>> listMigrationsAsync({
    required Uri csprojUri,
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
    required Uri csprojUri,
    required Uri configUri,
    MigrationHistory? migrationHistory,
  });

  /// Add new migration.
  /// **Arguments:**
  ///
  /// {@macro dotnet_ef6_service.DotnetEf6Service.listMigrationsAsync}
  /// - [migrationName] -> The migration to add.
  Future<void> addMigrationAsync({
    required Uri csprojUri,
    required Uri configUri,
    required String migrationName,
  });
}
