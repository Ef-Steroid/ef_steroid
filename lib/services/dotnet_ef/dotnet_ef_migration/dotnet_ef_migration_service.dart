abstract class DotnetEfMigrationService {
  static const String efMigrationFileExtension = 'cs';
  static const String efDesignerFileExtension = 'Designer.cs';
  static const String ef6ResourcesFileExtension = 'resx';

  static const List<String> ef6GeneratedMigrationFileExtensions = [
    efMigrationFileExtension,
    efDesignerFileExtension,
    ef6ResourcesFileExtension,
  ];

  static final RegExp migrationDesignerFileRegex = RegExp(
    r'\.' + efDesignerFileExtension + r'$',
    caseSensitive: false,
  );
  static final RegExp migrationResourcesFileRegex = RegExp(
    r'\.' + ef6ResourcesFileExtension + r'$',
    caseSensitive: false,
  );

  /// Get the migrations directory where Entity Framework saves all the migration files.
  Uri getMigrationsDirectory({
    required Uri projectUri,
  });
}
