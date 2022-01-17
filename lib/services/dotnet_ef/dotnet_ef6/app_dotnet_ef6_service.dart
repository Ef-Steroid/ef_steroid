import 'dart:convert';
import 'dart:io';

import 'package:async_task/async_task_extension.dart';
import 'package:fast_dotnet_ef/domain/migration_history.dart';
import 'package:fast_dotnet_ef/helpers/file_helper.dart';
import 'package:fast_dotnet_ef/services/cs_project_resolver/cs_project_resolver.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef6/dotnet_ef6_service.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef6/models/add_migration_dto.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef6/resolvers/dotnet_ef6_command_resolver.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_migration/dotnet_ef_migration_service.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:fast_dotnet_ef/services/process_runner/model/process_runner_result.dart';
import 'package:fast_dotnet_ef/services/process_runner/process_runner_service.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:quiver/strings.dart';
import 'package:xml/xml.dart';

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
  static final RegExp _dotnetDataRegex = RegExp(
    '^$_dotnetEfDataPrefix.*',
  );

  static const String _includeToken = 'Include';
  final LogService _logService;
  final DotnetEf6CommandResolver _dotnetEf6CommandResolver;
  final ProcessRunnerService _processRunnerService;
  final DotnetEfMigrationService _dotnetEfMigrationService;
  final CsProjectResolver _csProjectResolver;

  AppDotnetEf6Service(
    this._logService,
    this._dotnetEf6CommandResolver,
    this._processRunnerService,
    this._dotnetEfMigrationService,
    this._csProjectResolver,
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

  //region Add migration
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

    args.add(_dotnetEfJsonKey);

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

    switch (processRunnerResult.type) {
      case ProcessRunnerResultType.successful:
        runZonedGuarded(
          () {
            final stdout =
                (processRunnerResult as SuccessfulProcessRunnerResult).stdout ??
                    '';

            final migrationFilesJson = _extractJsonOutput(stdout);
            final addMigrationDto =
                AddMigrationDto.fromJson(jsonDecode(migrationFilesJson));
            _addMigrationFilesToCsprojAsync(
              projectUri: projectUri,
              addMigrationDto: addMigrationDto,
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
  Future<void> _addMigrationFilesToCsprojAsync({
    required Uri projectUri,
    required AddMigrationDto addMigrationDto,
    required String migrationName,
  }) async {
    final csprojRoot =
        await _csProjectResolver.getCsprojRootAsXml(projectUri: projectUri);

    final csprojFileParentDirectoryPath =
        _csProjectResolver.getCsprojFile(projectUri: projectUri).parent.path;

    // Attempt to figure out the csproj XML indent style.
    _writeToCompileSection(
      csprojRoot: csprojRoot,
      csprojFileParentDirectoryPath: csprojFileParentDirectoryPath,
      addMigrationDto: addMigrationDto,
    );

    _writeToEmbeddedResourceSection(
      csprojRoot: csprojRoot,
      csprojFileParentDirectoryPath: csprojFileParentDirectoryPath,
      addMigrationDto: addMigrationDto,
    );
    await _csProjectResolver.saveCsprojRootAsXml(
      csprojXml: csprojRoot,
      projectUri: projectUri,
    );
  }

  XmlElement _getItemGroupXmlElement({
    required XmlDocument csprojRoot,
    required String propertyName,
  }) {
    return csprojRoot.children
        .firstWhere((node) => node.nodeType == XmlNodeType.ELEMENT)
        .findElements('ItemGroup')
        .where(
          (x) => x.childElements.any((y) => y.name.local == propertyName),
        )
        .first;
  }

  String _getPathRelativeToCsprojFile({
    required String csprojFileParentDirectoryPath,
    required String path,
  }) {
    return p.relative(
      path,
      from: csprojFileParentDirectoryPath,
    );
  }

  void _writeToCompileSection({
    required XmlDocument csprojRoot,
    required String csprojFileParentDirectoryPath,
    required AddMigrationDto addMigrationDto,
  }) {
    const compileToken = 'Compile';
    final compileElement = _getItemGroupXmlElement(
      csprojRoot: csprojRoot,
      propertyName: compileToken,
    );
    final compiles = compileElement.children;
    final delimiter =
        compiles.firstWhere((node) => node.nodeType == XmlNodeType.TEXT);

    // TODO: Figure a way to optimize this. Currently, this is way too hacky.
    // XmlNodeList<XmlNode>.add method handles newline & tab internally.
    final leadingDelimiter = XmlText(delimiter.text.replaceFirst('\n    ', ''));
    final trailingDelimiter = XmlText(delimiter.text.replaceFirst('    ', ''));

    List<XmlNode> wrapWithDelimiter({
      required XmlElement xmlElement,
    }) {
      return [
        leadingDelimiter.copy(),
        xmlElement,
        trailingDelimiter.copy(),
      ];
    }

    void writeToItemGroup({
      required XmlElement xmlElement,
    }) {
      compiles.addAll(
        wrapWithDelimiter(
          xmlElement: xmlElement,
        ),
      );
    }

    writeToItemGroup(
      xmlElement: XmlElement(
        XmlName(compileToken),
        [
          XmlAttribute(
            XmlName(_includeToken),
            _getPathRelativeToCsprojFile(
              csprojFileParentDirectoryPath: csprojFileParentDirectoryPath,
              path: addMigrationDto.migration,
            ),
          ),
        ],
      ),
    );
    writeToItemGroup(
      xmlElement: XmlElement(
        XmlName(compileToken),
        [
          XmlAttribute(
            XmlName(_includeToken),
            _getPathRelativeToCsprojFile(
              csprojFileParentDirectoryPath: csprojFileParentDirectoryPath,
              path: addMigrationDto.migrationDesigner,
            ),
          ),
        ],
        wrapWithDelimiter(
          xmlElement: XmlElement(
            XmlName('DependentUpon'),
            [],
            [
              XmlText(p.basename(addMigrationDto.migration)),
            ],
          ),
        ),
      ),
    );
  }

  void _writeToEmbeddedResourceSection({
    required XmlDocument csprojRoot,
    required String csprojFileParentDirectoryPath,
    required AddMigrationDto addMigrationDto,
  }) {
    const embeddedResourceToken = 'EmbeddedResource';
    // TODO: Support adding new EmbeddedResource section.
    // This is going to fail if we support scaffolding Migration.
    final embeddedResourceElement = _getItemGroupXmlElement(
      csprojRoot: csprojRoot,
      propertyName: embeddedResourceToken,
    );
    final embeddedResources = embeddedResourceElement.children;
    final delimiter = embeddedResources
        .firstWhere((node) => node.nodeType == XmlNodeType.TEXT);

    // TODO: Figure a way to optimize this. Currently, this is way too hacky.
    // XmlNodeList<XmlNode>.add method handles newline & tab internally.
    final leadingDelimiter = XmlText(delimiter.text.replaceFirst('\n    ', ''));
    final trailingDelimiter = XmlText(delimiter.text.replaceFirst('    ', ''));

    List<XmlNode> wrapWithDelimiter({
      required XmlElement xmlElement,
    }) {
      return [
        leadingDelimiter.copy(),
        xmlElement,
        trailingDelimiter.copy(),
      ];
    }

    void writeToItemGroup({
      required XmlElement xmlElement,
    }) {
      embeddedResources.addAll(
        wrapWithDelimiter(
          xmlElement: xmlElement,
        ),
      );
    }

    writeToItemGroup(
      xmlElement: XmlElement(
        XmlName(embeddedResourceToken),
        [
          XmlAttribute(
            XmlName(_includeToken),
            _getPathRelativeToCsprojFile(
              csprojFileParentDirectoryPath: csprojFileParentDirectoryPath,
              path: addMigrationDto.migrationResources,
            ),
          ),
        ],
        wrapWithDelimiter(
          xmlElement: XmlElement(
            XmlName('DependentUpon'),
            [],
            [
              XmlText(p.basename(addMigrationDto.migration)),
            ],
          ),
        ),
      ),
    );
  }

  //endregion

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
}
