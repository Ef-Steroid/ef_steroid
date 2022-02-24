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

  await TestBootstrap.runAsync();
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
