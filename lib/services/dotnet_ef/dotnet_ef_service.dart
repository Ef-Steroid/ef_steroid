import 'package:fast_dotnet_ef/domain/migration_history.dart';

abstract class DotnetEfService {
  /// Update the database.
  ///
  /// **Arguments:**
  /// - [projectUri] -> The project uri.
  /// - [migrationHistory] -> The targeted migration history. Update to the
  /// latest if this is null.
  Future<String> updateDatabaseAsync({
    required Uri projectUri,
    MigrationHistory? migrationHistory,
  });

  /// List all the migrations.
  Future<List<MigrationHistory>> listMigrationsAsync({
    required Uri projectUri,
  });

  /// Add new migration.
  Future<void> addMigrationAsync({
    required Uri projectUri,
    required String migrationName,
  });

  /// Remove the last migration.
  ///
  /// Note that Dotnet EF supports only removing the last migration.
  ///
  /// **Arguments:**
  /// - [projectUri] -> The project uri.
  /// - [force] -> Force the migration removal even the migration is applied.
  Future<void> removeMigrationAsync({
    required Uri projectUri,
    required bool force,
  });
}
