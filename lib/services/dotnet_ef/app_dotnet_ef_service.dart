import 'dart:convert';

import 'package:fast_dotnet_ef/helpers/uri_helper.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/ef_model/migration_history.dart';
import 'package:fast_dotnet_ef/services/file/file_service.dart';
import 'package:fast_dotnet_ef/services/process_runner/model/process_runner_result.dart';
import 'package:fast_dotnet_ef/services/process_runner/process_runner_service.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:quiver/strings.dart';

@Injectable(as: DotnetEfService)
class AppDotnetEfService extends DotnetEfService {
  final FileService _fileService;
  final ProcessRunnerService _processRunnerService;

  static const String dotnetEfCommandName = 'dotnet-ef';

  static const String _dotnetEfProjectKey = '-p';

  static const String _dotnetEfJsonKey = '--json';
  static const String _dotnetEfPrefixOutputKey = '--prefix-output';
  static const String _dotnetEfNoBuildKey = '--no-build';

  static const String _dotnetEfDataPrefix = 'data:';
  static final RegExp _dotnetDataRegex = RegExp(
    '^$_dotnetEfDataPrefix.*',
    multiLine: true,
  );

  AppDotnetEfService(
    this._fileService,
    this._processRunnerService,
  );

  String get dotnetEfExecutable {
    return dotnetEfCommandName;
  }

  @override
  Future<String> updateDatabaseAsync({
    required Uri projectUri,
  }) async {
    final args = <String>[];

    // Add database command.
    args.add('database');

    // Add update command.
    args.add('update');

    // Add project option.
    args.add(_dotnetEfProjectKey);
    var projectPath = projectUri.toDecodedString();

    projectPath = _fileService.stripMacDiscFromPath(path: projectPath);

    args.add(projectPath);
    String result = '';

    final processRunnerResult = await _processRunnerService.runAsync(
      dotnetEfExecutable,
      args,
    );
    processRunnerResult.logResult();

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
  Future<List<MigrationHistory>> listMigrationAsync({
    required Uri projectUri,
  }) async {
    final args = <String>[];

    // Add migrations command.
    args.add('migrations');

    // Add list command.
    args.add('list');

    // Add project option.
    args.add(_dotnetEfProjectKey);
    var projectPath = projectUri.toDecodedString();

    projectPath = _fileService.stripMacDiscFromPath(path: projectPath);

    args.add(projectPath);

    args.add(_dotnetEfJsonKey);
    args.add(_dotnetEfPrefixOutputKey);
    var migrations = <MigrationHistory>[];
    final processRunnerResult = await _processRunnerService.runAsync(
      dotnetEfExecutable,
      args,
    );

    processRunnerResult.logResult();
    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        final extractedJsonOutput = _extractJsonOutput(
            (processRunnerResult as SuccessfulProcessRunnerResult).stdout);
        final decodedJson =
            isBlank(extractedJsonOutput) ? [] : jsonDecode(extractedJsonOutput);
        migrations = (decodedJson as List)
            .map((x) => MigrationHistory.fromJson(x))
            .toList(growable: false);
        break;
      case ProcessRunnerResultType.failure:
        break;
    }

    if (kDebugMode) {
      print(processRunnerResult.type);
    }

    return migrations;
  }

  String _extractJsonOutput(String? stdOut) {
    if (stdOut == null) return '';

    return _dotnetDataRegex
        .allMatches(stdOut)
        .map((e) => e.input
            .substring(e.start, e.end)
            .replaceAll(_dotnetEfDataPrefix, ''))
        .join()
        .replaceAll(RegExp(r'\s'), '');
  }
}
