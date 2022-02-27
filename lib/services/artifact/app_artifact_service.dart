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
