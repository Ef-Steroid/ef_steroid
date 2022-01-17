import 'dart:io';

import 'package:fast_dotnet_ef/domain/migration_history.dart';
import 'package:fast_dotnet_ef/helpers/file_helper.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef6/dotnet_ef6_service.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef6/resolvers/dotnet_ef6_command_resolver.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_migration/dotnet_ef_migration_service.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:fast_dotnet_ef/services/process_runner/model/process_runner_result.dart';
import 'package:fast_dotnet_ef/services/process_runner/process_runner_service.dart';
import 'package:injectable/injectable.dart';
import 'package:quiver/strings.dart';

@Injectable(as: DotnetEf6Service)
class AppDotnetEf6Service extends DotnetEf6Service {
  static const String _migrationsCommandName = 'migrations';
  static const String _databaseCommandName = 'database';

  static const String _dotnetEfDataPrefix = 'data:';
  static final RegExp _dotnetDataRegex = RegExp(
    '^$_dotnetEfDataPrefix.*',
  );

  final LogService _logService;
  final DotnetEf6CommandResolver _dotnetEf6CommandResolver;
  final ProcessRunnerService _processRunnerService;
  final DotnetEfMigrationService _dotnetEfMigrationService;

  AppDotnetEf6Service(
    this._logService,
    this._dotnetEf6CommandResolver,
    this._processRunnerService,
    this._dotnetEfMigrationService,
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
      'Start listing migration with command: ${_getFullCommand(
        ef6Command: ef6Command,
        args: args,
      )}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      ef6Command.commandName,
      _combineDotnetEf6CommandArgs(
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

  /// Compute the migration histories from added migrations written in
  /// `Migrations` directory.
  List<MigrationHistory> _computeMigrationHistories({
    required Uri projectUri,
    required List<String> appliedMigrations,
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
        .map((e) {
      final migrationId = e.fileName.replaceAll(
        DotnetEfMigrationService.migrationDesignerFileRegex,
        '',
      );
      return MigrationHistory.ef6(
        id: migrationId,
        applied: appliedMigrations.contains(migrationId),
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
          (x) => _dotnetDataRegex
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
      'Start updating database with command: ${_getFullCommand(
        ef6Command: ef6Command,
        args: args,
      )}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      ef6Command.commandName,
      _combineDotnetEf6CommandArgs(
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

  @override
  Future<void> addMigrationAsync({
    required Uri projectUri,
    required Uri configUri,
    required String migrationName,
  }) async {
    final args = <String>[];

    // Add migrations command.
    args.add(_migrationsCommandName);

    // Add list command.
    args.add('add');

    // Add migration id.
    args.add(migrationName);

    final ef6Command = await _dotnetEf6CommandResolver.getDotnetEf6CommandAsync(
      projectUri: projectUri,
      configUri: configUri,
    );

    _logService.info(
      'Start adding migration with command: ${_getFullCommand(
        ef6Command: ef6Command,
        args: args,
      )}',
    );

    final processRunnerResult = await _processRunnerService.runAsync(
      ef6Command.commandName,
      _combineDotnetEf6CommandArgs(
        ef6Command: ef6Command,
        args: args,
      ),
    );
    processRunnerResult.logResult();
  }

  String _getFullCommand({
    required Ef6Command ef6Command,
    required List<String> args,
  }) {
    return '${ef6Command.commandName} ${_combineDotnetEf6CommandArgs(
      ef6Command: ef6Command,
      args: args,
    ).join(' ')}';
  }

  List<String> _combineDotnetEf6CommandArgs({
    required Ef6Command ef6Command,
    required List<String> args,
  }) =>
      args + ef6Command.mandatoryArguments;
}
