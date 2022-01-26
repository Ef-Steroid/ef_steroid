import 'dart:io';

import 'package:ef_steroid/services/artifact/artifact_service.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

@Injectable(as: ArtifactService)
class AppArtifactService extends ArtifactService {
  @override
  String getCsprojToolExecutable() {
    final artifactsDirectory = _getArtifactDirectory();
    const csprojToolDirectoryName = 'CsprojTool';

    return p.joinAll([
      artifactsDirectory.path,
      csprojToolDirectoryName,
      'win-x64',
      'publish',
      '$csprojToolDirectoryName.exe',
    ]);
  }

  Directory _getArtifactDirectory() {
    if (!Platform.isWindows) {
      throw UnsupportedError('Artifact is not being supported on Windows yet');
    }
    final programExecutableFile = File(Platform.resolvedExecutable);
    return Directory(
      p.joinAll([
        programExecutableFile.parent.path,
        'artifacts',
      ]),
    );
  }
}
