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
          '${p.basename(projectUri.path)}$csProjectFileExtension',
        ]),
      );
}
