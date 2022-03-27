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

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_core/dotnet_ef_core_service.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_migration/dotnet_ef_migration_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

import '../test_bootstrap.dart';

Future<void> main() async {
  //region Testing projects relative path from project root.
  const netCoreWebProjectPath = 'tools/TestingProjects/EfCore/EfCoreWebProject';
  const migrationsDirectoryPath = '$netCoreWebProjectPath/Migrations';
  //endregion

  final rootProjectDirectory = TestBootstrap.getProjectRootDirectory();
  final netCoreWebProjectUri = Directory(
    p.joinAll([
      rootProjectDirectory.path,
      netCoreWebProjectPath,
    ]),
  ).uri;

  setUpAll(() async {
    await TestBootstrap.runAsync();
    await TestBootstrap.buildDotnetProjectAsync(
      projectUri: netCoreWebProjectUri,
    );
  });
  test(
    'AppDotnetEfCoreService.listMigrationAsync returns all migrations',
    () async {
      final dotnetEfCoreService = GetIt.I<DotnetEfCoreService>();
      final migrations = await dotnetEfCoreService.listMigrationsAsync(
        projectUri: Directory(
          p.joinAll([
            rootProjectDirectory.path,
            netCoreWebProjectPath,
          ]),
        ).uri,
        dbContextName: 'SchoolDbContext',
      );

      final migrationsDirectory = Directory(migrationsDirectoryPath);
      expect(await migrationsDirectory.exists(), true);

      final migrationsDesignerFileCount = migrationsDirectory
          .listSync()
          .where(
            (x) =>
                x.statSync().type == FileSystemEntityType.file &&
                DotnetEfMigrationService.migrationDesignerFileRegex
                    .hasMatch(x.path),
          )
          .length;

      expect(
        migrations.length,
        migrationsDesignerFileCount,
      );
    },
  );

  test(
    'AppDotnetEfCoreService.listDbContextsAsync returns all DbContexts',
    () async {
      final dotnetEf6Service = GetIt.I<DotnetEfCoreService>();
      final dbContexts = await dotnetEf6Service.listDbContextsAsync(
        projectUri: Directory(
          p.joinAll([
            rootProjectDirectory.path,
            netCoreWebProjectPath,
          ]),
        ).uri,
      );

      expect(
        dbContexts.length,
        2,
      );
      expect(
        const ListEquality().equals(
          dbContexts.map((x) => x.safeName).toList(),
          [
            'SchoolDbContext',
            'LibraryDbContext',
          ],
        ),
        true,
      );
    },
  );
}
