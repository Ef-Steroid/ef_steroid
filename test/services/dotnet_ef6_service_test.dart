import 'dart:io';

import 'package:fast_dotnet_ef/services/dotnet_ef6/dotnet_ef6_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;

import '../test_bootstrap.dart';

Future<void> main() async {
  //region Testing projects relative path from project root.
  const netFrameworkWebProjectPath =
      'tools/TestingProjects/Ef6/NetFrameworkWebProject';
  const netFrameworkWebProjectWebConfigPath =
      '$netFrameworkWebProjectPath/Web.config';
  const netFrameworkWebProjectCsprojFilePath =
      '$netFrameworkWebProjectPath/NetFrameworkWebProject.csproj';
  //endregion

  // This implementation takes advantage of the fact that Platform.script
  // returns `<Project root>/main.dart`.
  final rootProjectDirectory = File.fromUri(Platform.script).parent;

  await TestBootstrap.runAsync();

  final rootProjectDirectoryPath = rootProjectDirectory.path;
  final csprojUri = File(path.joinAll([
    rootProjectDirectoryPath,
    netFrameworkWebProjectCsprojFilePath,
  ])).uri;
  final configUri = File(path.joinAll([
    rootProjectDirectoryPath,
    netFrameworkWebProjectWebConfigPath,
  ])).uri;

  test(
    'AppDotnetEf6Service.listMigrationAsync returns all migrations',
    () async {
      final dotnetEf6Service = GetIt.I<DotnetEf6Service>();
      final migrations = await dotnetEf6Service.listMigrationAsync(
        csprojUri: csprojUri,
        configUri: configUri,
      );

      expect(migrations.length, 1);
    },
  );
}
