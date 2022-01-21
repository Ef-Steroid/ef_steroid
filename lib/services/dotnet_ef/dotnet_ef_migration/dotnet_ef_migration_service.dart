abstract class DotnetEfMigrationService {
  static const String ef6MigrationFileExtension = 'cs';
  static const String ef6DesignerFileExtension = 'Designer.cs';
  static const String efResourcesFileExtension = 'resx';

  static const List<String> ef6GeneratedMigrationFileExtensions = [
    ef6MigrationFileExtension,
    ef6DesignerFileExtension,
    efResourcesFileExtension,
  ];

  static final RegExp migrationDesignerFileRegex = RegExp(
    r'\.' + ef6DesignerFileExtension + r'$',
    caseSensitive: false,
  );
  static final RegExp migrationResourcesFileRegex = RegExp(
    r'\.' + efResourcesFileExtension + r'$',
    caseSensitive: false,
  );

  /// Get the migrations directory where Entity Framework saves all the migration files.
  Uri getMigrationsDirectory({
    required Uri projectUri,
  });
}
