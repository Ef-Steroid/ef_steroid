import 'dart:convert';
import 'dart:io';

import 'package:fast_dotnet_ef/exceptions/resolve_cs_project_exception.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef6/model/cs_project_asset.dart';
import 'package:fast_dotnet_ef/services/file/file_service.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

@injectable
class CsProjectResolver {
  final FileService _fileService;

  CsProjectResolver(
    this._fileService,
  );

  /// Get the project.asset.json file of [projectUri].
  ///
  /// **Arguments:**
  /// - [projectUri] -> The directory uri to the project
  Future<CsProjectAsset> getCsProjectAsset({
    required Uri projectUri,
  }) async {
    const buildObjectDirectoryName = 'obj';
    final projectPath =
        _fileService.stripMacDiscFromPath(path: projectUri.path);
    final buildObjectDirectory = Directory(
      p.join(
        projectPath,
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
}
