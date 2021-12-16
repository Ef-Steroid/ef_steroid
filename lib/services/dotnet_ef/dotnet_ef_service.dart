import 'package:fast_dotnet_ef/services/dotnet_ef/ef_model/migration_history.dart';

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
  Future<List<MigrationHistory>> listMigrationAsync({
    required Uri projectUri,
  });
}
