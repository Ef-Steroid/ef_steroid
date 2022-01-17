abstract class DotnetEfMigrationService {
  static final RegExp migrationDesignerFileRegex = RegExp(
    r'\.Designer.cs$',
    caseSensitive: false,
  );

  /// Get the migrations directory where Entity Framework saves all the migration files.
  Uri getMigrationsDirectory({
    required Uri projectUri,
  });
}
