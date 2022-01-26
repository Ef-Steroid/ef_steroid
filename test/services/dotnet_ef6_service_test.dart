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

  // This implementation takes advantage of the fact that Platform.script
  // returns `<Project root>/main.dart`.
  final rootProjectDirectory = File.fromUri(Platform.script).parent;

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
