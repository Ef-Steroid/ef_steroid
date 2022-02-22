import 'dart:convert';
import 'dart:io';

import 'package:async_task/async_task_extension.dart';
import 'package:ef_steroid/domain/migration_history.dart';
import 'package:ef_steroid/exceptions/dotnet_ef_exception.dart';
import 'package:ef_steroid/helpers/file_helper.dart';
import 'package:ef_steroid/services/artifact/artifact_service.dart';
import 'package:ef_steroid/services/cs_project_resolver/cs_project_resolver.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef6/dotnet_ef6_service.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef6/models/ef6_migration_dto.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef6/resolvers/dotnet_ef6_command_resolver.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_migration/dotnet_ef_migration_service.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_result_parser/data/dotnet_ef_result_type.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_result_parser/dotnet_ef_result_parser_service.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_result_parser/model/dotnet_ef_result_line.dart';
import 'package:ef_steroid/services/log/log_service.dart';
import 'package:ef_steroid/services/process_runner/model/process_runner_result.dart';
import 'package:ef_steroid/services/process_runner/process_runner_service.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:quiver/strings.dart';

@Injectable(as: DotnetEf6Service)
class AppDotnetEf6Service extends DotnetEf6Service {
  static const String _migrationsCommandName = 'migrations';
  static const String _databaseCommandName = 'database';

  /// The argument for outputting json.
  ///
  /// The global arguments of EF6 CLI does not contain json arguments. Therefore,
  /// we can only include it to those commands that support it; otherwise, EF6
  /// CLI throws error.
  static const String _dotnetEfJsonKey = '--json';

  static const String _dotnetEfDataPrefix = 'data:';
  static final RegExp _dotnetEfResultDataRegex = RegExp(
    '^$_dotnetEfDataPrefix.*',
    multiLine: true,
  );

  final LogService _logService;
  final DotnetEf6CommandResolver _dotnetEf6CommandResolver;
  final ProcessRunnerService _processRunnerService;
  final DotnetEfMigrationService _dotnetEfMigrationService;
  final CsProjectResolver _csProjectResolver;
  final ArtifactService _artifactService;
  final DotnetEfResultParserService _dotnetEfResultParserService;

  AppDotnetEf6Service(
    this._logService,
    this._dotnetEf6CommandResolver,
    this._processRunnerService,
    this._dotnetEfMigrationService,
    this._csProjectResolver,
    this._artifactService,
    this._dotnetEfResultParserService,
  );

  //region List migrations
  @override
  Future<List<MigrationHistory>> listMigrationsAsync({
    required Uri projectUri,
    required Uri configUri,
  }) async {
    final args = <String>[];

    // Add migrations command.
    args.add(_migrationsCommandName);

    // Add list command.
    args.add('list');

    final ef6Command = await _dotnetEf6CommandResolver.getDotnetEf6CommandAsync(
      projectUri: projectUri,
      configUri: configUri,
    );

    _logService.info(
      'Start listing migration with command: ${_getEf6CompleteCommand(
        ef6Command: ef6Command,
        args: args,
      )}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      executable: ef6Command.commandName,
      arguments: _combineDotnetEf6CommandArgs(
        ef6Command: ef6Command,
        args: args,
      ),
    );
    processRunnerResult.logResult();

    List<MigrationHistory> migrationHistories = <MigrationHistory>[];
    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        final stdout =
            (processRunnerResult as SuccessfulProcessRunnerResult).stdout;
        final appliedMigrations = _extractAppliedMigrations(stdout: stdout);
        migrationHistories = _computeMigrationHistories(
          projectUri: projectUri,
          appliedMigrations: appliedMigrations,
        );
        break;
      case ProcessRunnerResultType.failure:
        break;
    }

    return migrationHistories;
  }

  @override
  List<String> getLocalMigrations({
    required Uri projectUri,
  }) {
    return Directory.fromUri(
      _dotnetEfMigrationService.getMigrationsDirectory(
        projectUri: projectUri,
      ),
    )
        .listSync()
        .where(
          (x) =>
              x.statSync().type == FileSystemEntityType.file &&
              DotnetEfMigrationService.migrationDesignerFileRegex
                  .hasMatch(x.path),
        )
        .map(
          (e) => e.fileName.replaceAll(
            DotnetEfMigrationService.migrationDesignerFileRegex,
            '',
          ),
        )
        .toList(growable: false);
  }

  /// Compute the migration histories from added migrations written in
  /// `Migrations` directory.
  List<MigrationHistory> _computeMigrationHistories({
    required Uri projectUri,
    required List<String> appliedMigrations,
  }) {
    return getLocalMigrations(
      projectUri: projectUri,
    ).map((e) {
      return MigrationHistory.ef6(
        id: e,
        applied: appliedMigrations.contains(e),
      );
    }).toList(growable: false);
  }

  List<String> _extractAppliedMigrations({
    String? stdout,
  }) {
    if (stdout == null) return [];

    return stdout
        .split('\n')
        .map(
          (x) => _dotnetEfResultDataRegex
              .allMatches(x)
              .map(
                (e) => e.input
                    .substring(e.start, e.end)
                    .replaceAll(_dotnetEfDataPrefix, ''),
              )
              .join()
              .replaceAll(RegExp(r'\s'), ''),
        )
        .where((element) => isNotBlank(element))
        .toList(growable: false);
  }

  //endregion

  @override
  Future<String> updateDatabaseAsync({
    required Uri projectUri,
    required Uri configUri,
    MigrationHistory? migrationHistory,
  }) async {
    final args = <String>[];

    // Add database command.
    args.add(_databaseCommandName);

    args.add('update');

    if (migrationHistory != null &&
        // EF6 can only deal with applied migration.
        migrationHistory.applied) {
      args.add('--target');
      args.add(migrationHistory.id);
    }

    final ef6Command = await _dotnetEf6CommandResolver.getDotnetEf6CommandAsync(
      projectUri: projectUri,
      configUri: configUri,
    );

    _logService.info(
      'Start updating database with command: ${_getEf6CompleteCommand(
        ef6Command: ef6Command,
        args: args,
      )}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      executable: ef6Command.commandName,
      arguments: _combineDotnetEf6CommandArgs(
        ef6Command: ef6Command,
        args: args,
      ),
    );
    processRunnerResult.logResult();

    String result = '';
    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        result =
            (processRunnerResult as SuccessfulProcessRunnerResult).stdout ?? '';
        break;
      case ProcessRunnerResultType.failure:
        break;
    }

    return result;
  }

  //region Add migration
  @override
  Future<void> addMigrationAsync({
    required Uri projectUri,
    required Uri configUri,
    required String migrationName,
    required bool force,
    required bool ignoreChanges,
  }) async {
    final args = <String>[];

    // Add migrations command.
    args.add(_migrationsCommandName);

    args.add('add');

    // Add migration id.
    args.add(migrationName);

    if (force) {
      args.add('--force');
    }

    if (ignoreChanges) {
      args.add('--ignore-changes');
    }

    args.add(_dotnetEfJsonKey);

    final ef6Command = await _dotnetEf6CommandResolver.getDotnetEf6CommandAsync(
      projectUri: projectUri,
      configUri: configUri,
    );

    _logService.info(
      'Start adding migration with command: ${_getEf6CompleteCommand(
        ef6Command: ef6Command,
        args: args,
      )}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      executable: ef6Command.commandName,
      arguments: _combineDotnetEf6CommandArgs(
        ef6Command: ef6Command,
        args: args,
      ),
    );
    processRunnerResult.logResult();

    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        runZonedGuarded(
          () {
            final stdout =
                (processRunnerResult as SuccessfulProcessRunnerResult).stdout ??
                    '';

            final dotnetEfResultLines = _dotnetEfResultParserService
                .parseDotnetEfResult(stdout: stdout);

            bool testError(DotnetEfResultLine x) =>
                x.dotnetEfResultType == DotnetEfResultType.error;

            if (dotnetEfResultLines.any(testError)) {
              throw AddMigrationDotnetEf6Exception(
                errorMessage: dotnetEfResultLines
                    .where(testError)
                    .map((e) => e.line)
                    .join('')
                    .trim(),
              );
            }

            final migrationFilesJson = _dotnetEfResultParserService
                .extractJsonOutputFromDotnetEfResultLines(
              dotnetEfResultLines: dotnetEfResultLines,
            );
            final ef6MigrationDto =
                Ef6MigrationDto.fromJson(jsonDecode(migrationFilesJson));
            _addGeneratedMigrationFilesToCsprojAsync(
              projectUri: projectUri,
              ef6MigrationDto: ef6MigrationDto,
              migrationName: migrationName,
            );
          },
          (ex, stackTrace) {
            _logService.warning(
              'Fail to write generated migration files to csproj.',
              ex,
              stackTrace,
            );
          },
        );
        break;
      case ProcessRunnerResultType.failure:
        break;
    }
  }

  /// Add the generated migration files to <project-name>.csproj.
  ///
  /// We read the csproj file here to ensure it is up-to-date upon adding.
  Future<void> _addGeneratedMigrationFilesToCsprojAsync({
    required Uri projectUri,
    required Ef6MigrationDto ef6MigrationDto,
    required String migrationName,
  }) async {
    final args = <String>[];

    args.add('add-ef6-generated-migration-files');

    args.add('--csproj-path');

    final csprojFilePath =
        _csProjectResolver.getCsprojFile(projectUri: projectUri).path;
    args.add(csprojFilePath);

    args.add('--add-migration-dto');
    args.add(base64Encode(utf8.encode(jsonEncode(ef6MigrationDto))));

    final csprojToolExecutable = _artifactService.getCsprojToolExecutable();
    _logService.info(
      'Start adding migration to csproj file with command: ${_processRunnerService.getCompleteCommand(
        executable: csprojToolExecutable,
        args: args,
      )}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      executable: csprojToolExecutable,
      arguments: args,
    );
    processRunnerResult.logResult();
  }

  //endregion

  @override
  Future<void> removeMigrationAsync({
    required Uri projectUri,
    required MigrationHistory migrationHistory,
  }) {
    final deleteGeneratedMigrationFiles = Future.sync(() async {
      final generatedMigrationFiles = Directory.fromUri(
        _dotnetEfMigrationService.getMigrationsDirectory(
          projectUri: projectUri,
        ),
      ).listSync().where(
            (x) =>
                x.statSync().type == FileSystemEntityType.file &&
                DotnetEfMigrationService.ef6GeneratedMigrationFileExtensions
                    .any((y) => '${migrationHistory.id}.$y' == x.fileName),
          );

      for (final generatedMigrationFile in generatedMigrationFiles) {
        if (!(await generatedMigrationFile.exists())) continue;

        await generatedMigrationFile.delete();
      }
    });

    return Future.wait([
      deleteGeneratedMigrationFiles,
      _removeGeneratedMigrationFilesFromCsproj(
        migrationHistory: migrationHistory,
        projectUri: projectUri,
      ),
    ]);
  }

  Future<void> _removeGeneratedMigrationFilesFromCsproj({
    required Uri projectUri,
    required MigrationHistory migrationHistory,
  }) async {
    final migrationsDirectoryPath = _dotnetEfMigrationService
        .getMigrationsDirectory(
          projectUri: projectUri,
        )
        .path;

    String joinGeneratedMigrationFilePath({
      required String fileExtension,
    }) {
      return p.setExtension(
        p.joinAll([
          migrationsDirectoryPath,
          migrationHistory.id,
        ]),
        '.$fileExtension',
      );
    }

    final ef6MigrationDto = Ef6MigrationDto(
      migration: joinGeneratedMigrationFilePath(
        fileExtension: DotnetEfMigrationService.efMigrationFileExtension,
      ),
      migrationResources: joinGeneratedMigrationFilePath(
        fileExtension: DotnetEfMigrationService.ef6ResourcesFileExtension,
      ),
      migrationDesigner: joinGeneratedMigrationFilePath(
        fileExtension: DotnetEfMigrationService.efDesignerFileExtension,
      ),
    );

    final args = <String>[];

    args.add('remove-ef6-generated-migration-files');

    args.add('--csproj-path');

    final csprojFilePath =
        _csProjectResolver.getCsprojFile(projectUri: projectUri).path;
    args.add(csprojFilePath);

    args.add('--remove-migration-dto');
    args.add(base64Encode(utf8.encode(jsonEncode(ef6MigrationDto))));

    final csprojToolExecutable = _artifactService.getCsprojToolExecutable();
    _logService.info(
      'Start removing migration from csproj file with command: ${_processRunnerService.getCompleteCommand(
        executable: csprojToolExecutable,
        args: args,
      )}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      executable: csprojToolExecutable,
      arguments: args,
    );
    processRunnerResult.logResult();
  }

  String _getEf6CompleteCommand({
    required Ef6Command ef6Command,
    required List<String> args,
  }) {
    return _processRunnerService.getCompleteCommand(
      executable: ef6Command.commandName,
      args: _combineDotnetEf6CommandArgs(
        ef6Command: ef6Command,
        args: args,
      ),
    );
  }

  List<String> _combineDotnetEf6CommandArgs({
    required Ef6Command ef6Command,
    required List<String> args,
  }) =>
      args + ef6Command.mandatoryArguments;
}
