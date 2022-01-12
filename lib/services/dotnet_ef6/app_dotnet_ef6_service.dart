import 'package:fast_dotnet_ef/services/dotnet_ef/ef_model/migration_history.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef6/dotnet_ef6_service.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef6/resolvers/dotnet_ef6_command_resolver.dart';
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

  AppDotnetEf6Service(
    this._logService,
    this._dotnetEf6CommandResolver,
    this._processRunnerService,
  );

  @override
  Future<List<String>> listMigrationsAsync({
    required Uri csprojUri,
    required Uri configUri,
  }) async {
    final args = <String>[];

    // Add migrations command.
    args.add(_migrationsCommandName);

    // Add list command.
    args.add('list');

    final ef6Command = await _dotnetEf6CommandResolver.getDotnetEf6CommandAsync(
      csprojUri: csprojUri,
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

    List<String> result = <String>[];
    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        List<String> _extractMigrations() {
          final stdout =
              (processRunnerResult as SuccessfulProcessRunnerResult).stdout;
          if (stdout == null) return [];

          return stdout
              .split('\n')
              .map((x) => _dotnetDataRegex
                  .allMatches(x)
                  .map((e) => e.input
                      .substring(e.start, e.end)
                      .replaceAll(_dotnetEfDataPrefix, ''))
                  .join()
                  .replaceAll(RegExp(r'\s'), ''))
              .where((element) => isNotBlank(element))
              .toList(growable: false);
        }
        result = _extractMigrations();

        break;
      case ProcessRunnerResultType.failure:
        break;
    }

    return result;
  }

  @override
  Future<String> updateDatabaseAsync({
    required Uri csprojUri,
    required Uri configUri,
    MigrationHistory? migrationHistory,
  }) async {
    final args = <String>[];

    // Add database command.
    args.add(_databaseCommandName);

    args.add('update');

    if (migrationHistory != null) {
      args.add(migrationHistory.id);
    }

    final ef6Command = await _dotnetEf6CommandResolver.getDotnetEf6CommandAsync(
      csprojUri: csprojUri,
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
    required Uri csprojUri,
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
      csprojUri: csprojUri,
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
