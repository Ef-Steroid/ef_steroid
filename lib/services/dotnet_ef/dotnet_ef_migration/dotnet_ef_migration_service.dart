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
