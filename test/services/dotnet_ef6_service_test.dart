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

@TestOn('windows')
import 'dart:io';

import 'package:ef_steroid/services/dotnet_ef/dotnet_ef6/dotnet_ef6_service.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_migration/dotnet_ef_migration_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

import '../test_bootstrap.dart';

Future<void> main() async {
  //region Testing projects relative path from project root.
  const netFrameworkWebProjectPath =
      'tools/TestingProjects/Ef6/NetFrameworkWebProject';
  const migrationsDirectoryPath = '$netFrameworkWebProjectPath/Migrations';
  const netFrameworkWebProjectWebConfigPath =
      '$netFrameworkWebProjectPath/Web.config';
  //endregion

  final rootProjectDirectory = TestBootstrap.getProjectRootDirectory();

  await TestBootstrap.runAsync();

  final rootProjectDirectoryPath = rootProjectDirectory.path;
  final configUri = File(
    p.joinAll([
      rootProjectDirectoryPath,
      netFrameworkWebProjectWebConfigPath,
    ]),
  ).uri;

  test(
    'AppDotnetEf6Service.listMigrationAsync returns all migrations',
    () async {
      final dotnetEf6Service = GetIt.I<DotnetEf6Service>();
      final migrations = await dotnetEf6Service.listMigrationsAsync(
        projectUri: Directory(
          p.joinAll([
            rootProjectDirectoryPath,
            netFrameworkWebProjectPath,
          ]),
        ).uri,
        configUri: configUri,
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
}
