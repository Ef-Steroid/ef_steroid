import 'dart:io';

import 'package:fast_dotnet_ef/exceptions/resolve_dotnet_ef6_command_name_exception.dart';
import 'package:fast_dotnet_ef/services/cs_project_resolver/cs_project_resolver.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef6/data/cs_project_type.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/model/cs_project_asset.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

class Ef6Command {
  final String commandName;

  final List<String> mandatoryArguments;

  Ef6Command({
    required this.commandName,
    required this.mandatoryArguments,
  });
}

@injectable
class DotnetEf6CommandResolver {
  //region Get Dotnet EF6 executable path
  static const Set<String> _possibleTargetFrameworkVersionNodeNames = <String>{
    // Non-SDK style.
    'TargetFrameworkVersion',
    // SDK-style.
    'TargetFramework',
  };
  static const String _dotnetFrameworkTargetFrameworkVersionPrefix = 'v';

  static const String _propertyGroupToken = 'PropertyGroup';
  static const String _conditionToken = 'Condition';
  static const String _configurationToken = 'Configuration';

  final CsProjectResolver _csProjectResolver;

  DotnetEf6CommandResolver(
    this._csProjectResolver,
  );

  Future<Ef6Command> getDotnetEf6CommandAsync({
    required Uri projectUri,
    required Uri configUri,
  }) async {
    final readFilesResult = await Future.wait([
      _csProjectResolver.getCsProjectAsset(projectUri: projectUri),
      _csProjectResolver.getCsprojRootAsXml(projectUri: projectUri),
    ]);

    final csProjectAsset = readFilesResult[0] as CsProjectAsset;
    final csprojRoot = readFilesResult[1] as XmlDocument;

    final properties = csprojRoot.children
        .firstWhere((node) => node.nodeType == XmlNodeType.ELEMENT)
        .findElements(_propertyGroupToken)
        .where((x) => x.getAttribute(_conditionToken) == null)
        .first;

    final targetFrameworkVersion = _getTargetFrameworkVersionNumber(
      properties: properties,
      csProjectAsset: csProjectAsset,
    );
    final platformTarget = _getPlatformTarget(properties: properties);
    final entityFrameworkVersion = _getEntityFrameworkVersion(
      csProjectAsset: csProjectAsset,
    );

    return _detectEf6PathByFramework(
      csprojRoot: csprojRoot,
      properties: properties,
      projectDirectory: Directory.fromUri(projectUri),
      csProjectAsset: csProjectAsset,
      targetFrameworkVersion: targetFrameworkVersion,
      platformTarget: platformTarget,
      entityFrameworkVersion: entityFrameworkVersion,
      configUri: configUri,
    );
  }

  /// Get the target framework version based on the [project format](https://docs.microsoft.com/en-us/nuget/resources/check-project-format).
  int _getTargetFrameworkVersionNumber({
    required XmlElement properties,
    required CsProjectAsset csProjectAsset,
  }) {
    var targetFrameworkVersion = properties.children
        .firstWhere(
          (node) =>
              node is XmlElement &&
              _possibleTargetFrameworkVersionNodeNames
                  .contains(node.name.local),
        )
        .innerText;

    switch (csProjectAsset.csProjectType) {
      case CsProjectType.netCore:
        targetFrameworkVersion = targetFrameworkVersion.replaceFirst('net', '');
        break;
      case CsProjectType.netFramework:
        targetFrameworkVersion = targetFrameworkVersion.replaceFirst(
          _dotnetFrameworkTargetFrameworkVersionPrefix,
          '',
        );
        break;
    }
    final targetFrameworkVersionNumber = int.tryParse(
      targetFrameworkVersion.replaceAll('.', '').padRight(3, '0'),
    );

    if (targetFrameworkVersionNumber == null) {
      throw ResolveDotnetEf6CommandNameException.invalidTargetFrameworkVersion(
        targetFrameworkVersion: targetFrameworkVersion,
      );
    }

    return targetFrameworkVersionNumber;
  }

  String _getConfiguration({
    required XmlElement properties,
  }) =>
      _getProperty(
        properties: properties,
        propertyName: _configurationToken,
      );

  String _getPlatformTarget({
    required XmlElement properties,
  }) =>
      _getProperty(
        properties: properties,
        propertyName: 'Platform',
      );

  String? _getRootNamespace({
    required XmlElement properties,
  }) =>
      _tryGetProperty(
        properties: properties,
        propertyName: 'RootNamespace',
      );

  String? _tryGetProperty({
    required XmlElement properties,
    required String propertyName,
  }) {
    final elements = properties.findElements(propertyName);
    if (elements.isEmpty) {
      return null;
    }
    return elements.first.innerText;
  }

  String _getProperty({
    required XmlElement properties,
    required String propertyName,
  }) =>
      properties.findElements(propertyName).first.innerText;

  /// Get output path.
  ///
  /// Output path contains the current project configuration. Typically 'Debug'.
  String _getOutputPath({
    required XmlDocument csprojRoot,
    required XmlElement properties,
  }) {
    final currentProjectConfiguration =
        _getConfiguration(properties: properties);
    final platformTarget = _getPlatformTarget(properties: properties);

    final buildConfigurationPropertyGroup = csprojRoot
        .findAllElements(_propertyGroupToken)
        .firstWhere(
          (x) =>
              x
                  .getAttribute(_conditionToken)
                  ?.contains('$currentProjectConfiguration|$platformTarget') ??
              false,
        );
    return buildConfigurationPropertyGroup
        .findElements('OutputPath')
        .first
        .innerText;
  }

  String _getEntityFrameworkVersion({
    required CsProjectAsset csProjectAsset,
  }) {
    try {
      final entityFrameworkPackageRegex = RegExp('^EntityFramework/');
      return csProjectAsset.libraries.entries
          .firstWhere((x) {
            return entityFrameworkPackageRegex.hasMatch(x.key);
          })
          .key
          .replaceFirst(entityFrameworkPackageRegex, '');
    } on StateError catch (_) {
      throw ResolveDotnetEf6CommandNameException
          .noEntityFrameworkPackageFound();
    }
  }

  String _getProgrammingLanguage() {
    // No idea how to detect other projects. Not enough sample.
    return 'C#';
  }

  /// Detect framework directory based on [here](https://docs.microsoft.com/en-us/dotnet/standard/frameworks).
  ///
  /// This implementation is based on ~/.nuget/packages/entityframework/<framework-version>/tools/EntityFramework6.psm1.
  Ef6Command _detectEf6PathByFramework({
    required XmlDocument csprojRoot,
    required XmlElement properties,
    required Directory projectDirectory,
    required CsProjectAsset csProjectAsset,
    required int targetFrameworkVersion,
    required String platformTarget,
    required String entityFrameworkVersion,
    required Uri configUri,
  }) {
    const net45VersionNumber = 450;
    String frameworkDir = 'net45';
    if (targetFrameworkVersion < net45VersionNumber) {
      frameworkDir = 'net40';
    }

    switch (csProjectAsset.csProjectType) {
      case CsProjectType.netCore:
        throw ResolveDotnetEf6CommandNameException.unsupportedFramework();

      case CsProjectType.netFramework:
        String runtimeDir;
        if (platformTarget == 'x86') {
          runtimeDir = 'win-x86';
        } else if (<String>{
          'AnyCPU',
          'x64',
        }.contains(platformTarget)) {
          runtimeDir = 'any';
        } else {
          throw ResolveDotnetEf6CommandNameException.invalidRuntimeTarget(
            platformTarget: platformTarget,
          );
        }

        final outputPath = _getOutputPath(
          csprojRoot: csprojRoot,
          properties: properties,
        );
        final targetDir = p.join(
          projectDirectory.path,
          outputPath,
        );

        // The respective script points to OutputFileName which comes out of
        // nowhere. We end up using the projectName in project.assets.json.
        // Since there is no guarantee that projectName exists, we force to
        // throw here.
        // TODO: Figure out a way to handle this better.
        final targetFileName = csProjectAsset.project.restore.projectName!;
        final targetPath = p.join(targetDir, '$targetFileName.dll');
        final rootNamespace = _getRootNamespace(properties: properties);
        final language = _getProgrammingLanguage();

        return Ef6Command(
          commandName: p.joinAll([
            if (Platform.isWindows)
              Platform.environment['USERPROFILE'].toString()
            else
              Platform.environment['HOME'].toString(),
            '.nuget',
            'packages',
            'entityframework',
            entityFrameworkVersion,
            'tools',
            frameworkDir,
            runtimeDir,
            'ef6.exe',
          ]),
          mandatoryArguments: [
            '--verbose',
            '--prefix-output',
            '--assembly',
            targetPath,
            '--project-dir',
            projectDirectory.path,
            '--language',
            language,
            if (rootNamespace != null) ...[
              '--root-namespace',
              rootNamespace,
            ],
            '--config',
            // Parse to file is necessary because Uri.path contains leading slash.
            configUri.toFilePath(),
          ],
        );
    }
  }

//endregion
}
