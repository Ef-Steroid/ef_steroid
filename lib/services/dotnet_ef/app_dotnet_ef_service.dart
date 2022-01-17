import 'dart:convert';

import 'package:fast_dotnet_ef/exceptions/dotnet_ef_exception.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/domain/migration_history.dart';
import 'package:fast_dotnet_ef/services/file/file_service.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:fast_dotnet_ef/services/process_runner/model/process_runner_result.dart';
import 'package:fast_dotnet_ef/services/process_runner/process_runner_service.dart';
import 'package:injectable/injectable.dart';
import 'package:quiver/strings.dart';

@Injectable(as: DotnetEfService)
class AppDotnetEfService extends DotnetEfService {
  final FileService _fileService;
  final ProcessRunnerService _processRunnerService;
  final LogService _logService;

  static const String _dotnetEfCommandName = 'dotnet-ef';
  static const String _migrationsCommandName = 'migrations';
  static const String _databaseCommandName = 'database';

  static const String _dotnetEfProjectKey = '-p';

  static const String _dotnetEfJsonKey = '--json';
  static const String _dotnetEfPrefixOutputKey = '--prefix-output';

  static const String _dotnetEfDataPrefix = 'data:';
  static final RegExp _dotnetDataRegex = RegExp(
    '^$_dotnetEfDataPrefix.*',
    multiLine: true,
  );
  static const String _dotnetEfErrorPrefix = 'error:';
  static final RegExp _dotnetErrorRegex = RegExp(
    '^$_dotnetEfErrorPrefix.*',
    multiLine: true,
  );

  AppDotnetEfService(
    this._fileService,
    this._processRunnerService,
    this._logService,
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
      _dotnetEfCommandName,
      args,
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

    args.add(_dotnetEfJsonKey);
    args.add(_dotnetEfPrefixOutputKey);

    _logService.info(
      'Start listing migration with command: ${_getFullCommand(args)}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      _dotnetEfCommandName,
      args,
    );
    processRunnerResult.logResult();

    var migrations = <MigrationHistory>[];
    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        final extractedJsonOutput = _extractJsonOutput(
          (processRunnerResult as SuccessfulProcessRunnerResult).stdout,
        );
        final decodedJson =
            isBlank(extractedJsonOutput) ? [] : jsonDecode(extractedJsonOutput);
        migrations = (decodedJson as List)
            .map((x) => MigrationHistory.fromJson(x))
            .toList(growable: false);
        break;
      case ProcessRunnerResultType.failure:
        break;
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
      _dotnetEfCommandName,
      args,
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

    args.add(_dotnetEfJsonKey);
    args.add(_dotnetEfPrefixOutputKey);

    _logService.info(
      'Start removing migration with command: ${_getFullCommand(args)}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      _dotnetEfCommandName,
      args,
    );
    processRunnerResult.logResult();

    final successfulProcessRunnerResult =
        (processRunnerResult as SuccessfulProcessRunnerResult);
    final stdout = successfulProcessRunnerResult.stdout;
    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        if (stdout != null && _dotnetErrorRegex.hasMatch(stdout)) {
          throw RemoveMigrationDotnetEfException(
            errorMessage: _extractErrorFromStdout(stdout),
          );
        }
        break;
      case ProcessRunnerResultType.failure:
        break;
    }
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

  String _extractJsonOutput(String? stdout) {
    if (stdout == null) return '';

    return _dotnetDataRegex
        .allMatches(stdout)
        .map(
          (e) => e.input
              .substring(e.start, e.end)
              .replaceAll(_dotnetEfDataPrefix, ''),
        )
        .join()
        .replaceAll(RegExp(r'\s'), '');
  }

  /// EFCore returns the error part of the [stdout]. We can filter it by looking
  /// for 'error:' in the [stdout].
  String _extractErrorFromStdout(String? stdout) {
    if (stdout == null) return '';

    return _dotnetErrorRegex
        .allMatches(stdout)
        .map(
          (e) => e.input
              .substring(e.start, e.end)
              .replaceAll(_dotnetEfErrorPrefix, ''),
        )
        .join()
        .trim();
  }

  String _getFullCommand(List<String> args) {
    return '$_dotnetEfCommandName ${args.join(' ')}';
  }
}
