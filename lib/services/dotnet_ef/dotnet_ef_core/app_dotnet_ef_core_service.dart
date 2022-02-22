import 'dart:convert';

import 'package:ef_steroid/domain/migration_history.dart';
import 'package:ef_steroid/exceptions/dotnet_ef_exception.dart';
import 'package:ef_steroid/exceptions/process_runner_exception.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_core/dotnet_ef_core_service.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_result_parser/dotnet_ef_result_parser_service.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_result_parser/model/dotnet_ef_result_line.dart';
import 'package:ef_steroid/services/dotnet_ef/model/db_context.dart';
import 'package:ef_steroid/services/file/file_service.dart';
import 'package:ef_steroid/services/log/log_service.dart';
import 'package:ef_steroid/services/process_runner/model/process_runner_result.dart';
import 'package:ef_steroid/services/process_runner/process_runner_service.dart';
import 'package:injectable/injectable.dart';
import 'package:quiver/strings.dart';

@Injectable(as: DotnetEfCoreService)
class AppDotnetEfCoreService extends DotnetEfCoreService {
  final FileService _fileService;
  final ProcessRunnerService _processRunnerService;
  final LogService _logService;
  final DotnetEfResultParserService _dotnetEfResultParserService;

  static const String _dotnetEfCommandName = 'dotnet-ef';

  static const String _migrationsCommandName = 'migrations';
  static const String _databaseCommandName = 'database';
  static const String _dbContextCommandName = 'dbcontext';

  static const String _dotnetEfProjectKey = '-p';

  static const String _dotnetEfJsonKey = '--json';
  static const String _dotnetEfPrefixOutputKey = '--prefix-output';

  AppDotnetEfCoreService(
    this._fileService,
    this._processRunnerService,
    this._logService,
    this._dotnetEfResultParserService,
  );

  @override
  Future<String> updateDatabaseAsync({
    required Uri projectUri,
    MigrationHistory? migrationHistory,
  }) async {
    final args = <String>[];

    // Add database command.
    args.add(_databaseCommandName);

    // Add update command.
    args.add('update');

    if (migrationHistory != null) {
      args.add(migrationHistory.id);
    }

    // Add project option.
    _addProjectOption(
      args: args,
      projectUri: projectUri,
    );

    _logService.info(
      'Start updating database with command: ${_getFullCommand(args)}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      executable: _dotnetEfCommandName,
      arguments: args,
    );
    processRunnerResult.logResult();

    String result = '';
    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        result =
            (processRunnerResult as SuccessfulProcessRunnerResult).stdout ?? '';
        break;
      case ProcessRunnerResultType.failure:
        throw ProcessRunnerException.fromFailureProcessRunnerResult(
          failureProcessRunnerResult:
              processRunnerResult as FailureProcessRunnerResult,
        );
    }

    return result;
  }

  @override
  Future<List<MigrationHistory>> listMigrationsAsync({
    required Uri projectUri,
  }) async {
    final args = <String>[];

    // Add migrations command.
    args.add(_migrationsCommandName);

    // Add list command.
    args.add('list');

    // Add project option.
    _addProjectOption(
      args: args,
      projectUri: projectUri,
    );

    _requestJsonOutput(args: args);

    _logService.info(
      'Start listing migration with command: ${_getFullCommand(args)}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      executable: _dotnetEfCommandName,
      arguments: args,
    );
    processRunnerResult.logResult();

    var migrations = <MigrationHistory>[];
    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        final extractedJsonOutput =
            _dotnetEfResultParserService.extractJsonOutput(
          stdout: (processRunnerResult as SuccessfulProcessRunnerResult).stdout,
        );
        final decodedJson =
            isBlank(extractedJsonOutput) ? [] : jsonDecode(extractedJsonOutput);
        migrations = (decodedJson as List)
            .map((x) => MigrationHistory.fromJson(x))
            .toList(growable: false);
        break;
      case ProcessRunnerResultType.failure:
        throw ProcessRunnerException.fromFailureProcessRunnerResult(
          failureProcessRunnerResult:
              processRunnerResult as FailureProcessRunnerResult,
        );
    }

    return migrations;
  }

  @override
  Future<void> addMigrationAsync({
    required Uri projectUri,
    required String migrationName,
  }) async {
    final args = <String>[];

    // Add migrations command.
    args.add(_migrationsCommandName);

    // Add add command.
    args.add('add');

    // Add migration id.
    args.add(migrationName);

    // Add project option.
    _addProjectOption(
      args: args,
      projectUri: projectUri,
    );

    _logService.info(
      'Start adding migration with command: ${_getFullCommand(args)}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      executable: _dotnetEfCommandName,
      arguments: args,
    );
    processRunnerResult.logResult();
  }

  @override
  Future<void> removeMigrationAsync({
    required Uri projectUri,
    required bool force,
  }) async {
    final args = <String>[];

    // Add migrations command.
    args.add(_migrationsCommandName);

    // Add remove command.
    args.add('remove');

    // Add project option.
    _addProjectOption(
      args: args,
      projectUri: projectUri,
    );

    if (force) {
      args.add('--force');
    }

    _requestJsonOutput(args: args);

    _logService.info(
      'Start removing migration with command: ${_getFullCommand(args)}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      executable: _dotnetEfCommandName,
      arguments: args,
    );
    processRunnerResult.logResult();

    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        final successfulProcessRunnerResult =
            (processRunnerResult as SuccessfulProcessRunnerResult);
        final stdout = successfulProcessRunnerResult.stdout;
        if (stdout != null) {
          final dotnetEfResultLines =
              _dotnetEfResultParserService.parseDotnetEfResult(stdout: stdout);

          if (dotnetEfResultLines.hasError) {
            throw RemoveMigrationDotnetEfException(
              errorMessage: dotnetEfResultLines.errorLines
                  .map((e) => e.line)
                  .join('')
                  .trim(),
            );
          }
        }
        break;
      case ProcessRunnerResultType.failure:
        throw ProcessRunnerException.fromFailureProcessRunnerResult(
          failureProcessRunnerResult:
              processRunnerResult as FailureProcessRunnerResult,
        );
    }
  }

  @override
  Future<List<DbContext>> listDbContextsAsync({
    required Uri projectUri,
  }) async {
    final args = <String>[];

    // Add dbcontext command.
    args.add(_dbContextCommandName);

    // Add list command.
    args.add('list');

    // Add project option.
    _addProjectOption(
      args: args,
      projectUri: projectUri,
    );

    _requestJsonOutput(args: args);

    _logService.info(
      'Start listing dbcontexts with command: ${_getFullCommand(args)}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      executable: _dotnetEfCommandName,
      arguments: args,
    );
    processRunnerResult.logResult();

    var dbContexts = <DbContext>[];
    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        final successfulProcessRunnerResult =
            (processRunnerResult as SuccessfulProcessRunnerResult);
        final stdout = successfulProcessRunnerResult.stdout;
        if (stdout != null) {
          final dotnetEfResultLines =
              _dotnetEfResultParserService.parseDotnetEfResult(stdout: stdout);

          if (dotnetEfResultLines.hasError) {
            throw ListDbContextsDotnetEfException(
              errorMessage: dotnetEfResultLines.errorLines
                  .map((e) => e.line)
                  .join('')
                  .trim(),
            );
          }
          final extractedJsonOutput =
              _dotnetEfResultParserService.extractJsonOutput(
            stdout: successfulProcessRunnerResult.stdout,
          );
          final decodedJson = isBlank(extractedJsonOutput)
              ? []
              : jsonDecode(extractedJsonOutput);
          dbContexts =
              (decodedJson as List).map((e) => DbContext.fromJson(e)).toList();
        }
        break;

      case ProcessRunnerResultType.failure:
        throw ProcessRunnerException.fromFailureProcessRunnerResult(
          failureProcessRunnerResult:
              processRunnerResult as FailureProcessRunnerResult,
        );
    }

    return dbContexts;
  }

  void _requestJsonOutput({required List<String> args}) {
    args.add(_dotnetEfJsonKey);
    args.add(_dotnetEfPrefixOutputKey);
  }

  void _addProjectOption({
    required List<String> args,
    required Uri projectUri,
  }) {
    args.add(_dotnetEfProjectKey);
    var projectPath = projectUri.toFilePath();

    projectPath = _fileService.stripMacDiscFromPath(path: projectPath);

    args.add(projectPath);
  }

  String _getFullCommand(List<String> args) {
    return _processRunnerService.getCompleteCommand(
      executable: _dotnetEfCommandName,
      args: args,
    );
  }
}
