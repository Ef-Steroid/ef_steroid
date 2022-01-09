abstract class DotnetEf6Service {
  /// Update the database.
  ///
  /// **Arguments:**
  /// - [csprojUri] -> The project uri.
  /// - [migrationHistory] -> The targeted migration history. Update to the
  /// latest if this is null.
  /*Future<String> updateDatabaseAsync({
    required Uri projectUri,
    MigrationHistory? migrationHistory,
  });*/

  /// List all the migrations.
  ///
  /// **Arguments:**
  /// - [csprojUri] -> The EntityFramework project uri.
  /// - [configUri] -> The Web.config uri.
  Future<List<String>> listMigrationAsync({
    required Uri csprojUri,
    required Uri configUri,
  });
}
