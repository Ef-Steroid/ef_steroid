import 'package:fast_dotnet_ef/services/dotnet_ef/ef_model/migration_history.dart';

abstract class DotnetEfService {
  /// Update the database.
  Future<String> updateDatabaseAsync({
    required Uri projectUri,
  });

  /// List all the migrations.
  Future<List<MigrationHistory>> listMigrationAsync({
    required Uri projectUri,
  });
}
