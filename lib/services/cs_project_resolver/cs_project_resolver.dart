import 'dart:convert';
import 'dart:io';

import 'package:ef_steroid/exceptions/resolve_cs_project_exception.dart';
import 'package:ef_steroid/exceptions/resolve_csproj_exception.dart';
import 'package:ef_steroid/services/dotnet_ef/model/cs_project_asset.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

@injectable
class CsProjectResolver {
  static const String csProjectFileExtension = '.csproj';

  CsProjectResolver();

  /// Get the project.asset.json file of [projectUri].
  ///
  /// **Arguments:**
  /// - [projectUri] -> The directory uri to the project
  Future<CsProjectAsset> getCsProjectAsset({
    required Uri projectUri,
  }) async {
    const buildObjectDirectoryName = 'obj';
    final buildObjectDirectory = Directory(
      p.join(
        projectUri.toFilePath(),
        buildObjectDirectoryName,
      ),
    );

    if (!(await buildObjectDirectory.exists())) {
      throw ResolveCsProjectException.projectNotBuild(
        lookup: buildObjectDirectoryName,
      );
    }

    const projectAssetsJsonFileName = 'project.assets.json';
    final projectAssetsJsonFile = File(
      p.join(
        buildObjectDirectory.path,
        projectAssetsJsonFileName,
      ),
    );
    if (!(await projectAssetsJsonFile.exists())) {
      throw ResolveCsProjectException.projectNotBuild(
        lookup: projectAssetsJsonFileName,
      );
    }

    final projectAssetsJson =
        jsonDecode(await projectAssetsJsonFile.readAsString());

    CsProjectAsset csProjectAsset;
    try {
      csProjectAsset = CsProjectAsset.fromJson(projectAssetsJson);
    } catch (e) {
      throw ResolveCsProjectException.projectAssetJsonParsingFailure(
        projectAssetJsonPath: projectAssetsJsonFile.path,
      );
    }

    return csProjectAsset;
  }

  Future<XmlDocument> getCsprojRootAsXml({
    required Uri projectUri,
  }) async {
    final csprojFile = getCsprojFile(projectUri: projectUri);
    if (!(await csprojFile.exists())) {
      throw ResolveCsprojException.csprojFileNotFound(
        csprojUri: projectUri,
      );
    }

    return XmlDocument.parse(
      await csprojFile.readAsString(),
    );
  }

  Future<void> saveCsprojRootAsXml({
    required XmlDocument csprojXml,
    required Uri projectUri,
  }) {
    final csprojFile = getCsprojFile(projectUri: projectUri);
    return csprojFile.writeAsString(
      csprojXml.toXmlString(),
    );
  }

  File getCsprojFile({
    required Uri projectUri,
  }) =>
      File(
        p.joinAll([
          projectUri.toFilePath(),
          // csproj file is the same as the project name.
          '${p.basenameWithoutExtension(projectUri.path)}$csProjectFileExtension',
        ]),
      );
}
