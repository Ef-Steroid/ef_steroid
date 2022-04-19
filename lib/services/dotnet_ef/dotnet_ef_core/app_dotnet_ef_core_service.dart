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
import 'package:ef_steroid/services/process_runner/process_runner_type.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:quiver/strings.dart';

@Injectable(as: DotnetEfCoreService)
class AppDotnetEfCoreService extends DotnetEfCoreService {
  final FileService _fileService;
  final ProcessRunnerService _processRunnerService =
      GetIt.I<ProcessRunnerService>(
    param1: ProcessRunnerType.efCore,
  );
  final LogService _logService;
  final DotnetEfResultParserService _dotnetEfResultParserService;

  static const String _dotnetEfCommandName = 'dotnet-ef';

  static const String _migrationsCommandName = 'migrations';
  static const String _databaseCommandName = 'database';
  static const String _dbContextCommandName = 'dbcontext';

  static const String _dotnetEfProjectKey = '-p';

  static const String _dotnetEfJsonKey = '--json';
  static const String _dotnetEfPrefixOutputKey = '--prefix-output';
  static const String _dotnetEfContextKey = '--context';

  AppDotnetEfCoreService(
    this._fileService,
    this._logService,
    this._dotnetEfResultParserService,
  );

  @override
  Future<String> updateDatabaseAsync({
    required Uri projectUri,
    MigrationHistory? migrationHistory,
    String? dbContextName,
  }) async {
    final args = <String>[];

    // Add database command.
    args.add(_databaseCommandName);

    // Add update command.
    args.add('update');

    if (migrationHistory != null) {
      args.add(migrationHistory.id);
    }

    // Add context command.
    _addDbContext(
      args: args,
      dbContextName: dbContextName,
    );

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
    String? dbContextName,
  }) async {
    final args = <String>[];

    // Add migrations command.
    args.add(_migrationsCommandName);

    // Add list command.
    args.add('list');

    // Add context command.
    _addDbContext(
      args: args,
      dbContextName: dbContextName,
    );

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

    var migrations = <MigrationHistory>[];
    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        final stdout =
            (processRunnerResult as SuccessfulProcessRunnerResult).stdout;
        if (stdout != null) {
          final dotnetEfResultLines =
              _dotnetEfResultParserService.parseDotnetEfResult(
            stdout: stdout,
          );
          if (dotnetEfResultLines.hasError) {
            throw UnknownDotnetEfException(
              errorMessage: dotnetEfResultLines.errorLines
                  .map((e) => e.line)
                  .join('')
                  .trim(),
            );
          }
          final extractedJsonOutput = _dotnetEfResultParserService
              .extractJsonOutputFromDotnetEfResultLines(
            dotnetEfResultLines: dotnetEfResultLines,
          );
          final decodedJson = isBlank(extractedJsonOutput)
              ? []
              : jsonDecode(extractedJsonOutput);
          migrations = (decodedJson as List)
              .map((x) => MigrationHistory.fromJson(x))
              .toList(growable: false);
        }
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
    String? dbContextName,
  }) async {
    final args = <String>[];

    // Add migrations command.
    args.add(_migrationsCommandName);

    // Add add command.
    args.add('add');

    // Add migration id.
    args.add(migrationName);

    // Add context command.
    _addDbContext(
      args: args,
      dbContextName: dbContextName,
    );

    // Add project option.
    _addProjectOption(
      args: args,
      projectUri: projectUri,
    );

    _logService.info(
      'Start adding migration with command: ${_getFullCommand(args)}',
    );

    await _processRunnerService.runAsync(
      executable: _dotnetEfCommandName,
      arguments: args,
    );
  }

  void _addDbContext({
    required List<String> args,
    required String? dbContextName,
  }) {
    if (isBlank(dbContextName)) {
      return;
    }
    args.add(_dotnetEfContextKey);
    args.add(dbContextName!);
  }

  @override
  Future<void> removeMigrationAsync({
    required Uri projectUri,
    required bool force,
    String? dbContextName,
  }) async {
    final args = <String>[];

    // Add migrations command.
    args.add(_migrationsCommandName);

    // Add remove command.
    args.add('remove');

    // Add context command.
    _addDbContext(
      args: args,
      dbContextName: dbContextName,
    );

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
            throw UnknownDotnetEfException(
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
