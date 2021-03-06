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

import 'package:ef_steroid/services/dotnet_ef/dotnet_ef6/data/cs_project_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cs_project_asset.g.dart';

@JsonSerializable(
  // It is meaningless to generate toJson. This is a one-way parsing from
  // project.assets.json.
  createToJson: false,
)
class CsProjectAsset {
  static List<String> _targetsFromJsonFactory(Map<String, dynamic> json) {
    return json.keys.toList();
  }

  @JsonKey(
    fromJson: _targetsFromJsonFactory,
  )
  final List<String> targets;

  /// The key contains the package name and version. The value ([LibraryInfo])
  /// contains other useful information.
  ///
  /// Eg:
  ///  "EntityFramework/6.4.4": {
  ///       "sha512": "yj1+/4tci7Panu3jKDHYizxwVm0Jvm7b7m057b5h4u8NUHGCR8WIWirBTw+8EptRffwftIWPBeIRGNKD1ewEMQ==",
  ///       "type": "package",
  ///       "path": "entityframework/6.4.4",
  ///       "hasTools": true,
  ///       "files": [
  ///         ".nupkg.metadata",
  ///         ".signature.p7s",
  ///         "Icon.png",
  ///         "build/EntityFramework.DefaultItems.props",
  ///         "build/EntityFramework.props",
  ///         "build/EntityFramework.targets",
  ///         "build/Microsoft.Data.Entity.Build.Tasks.dll",
  ///         "build/netcoreapp3.0/EntityFramework.props",
  ///         "build/netcoreapp3.0/EntityFramework.targets",
  ///         "buildTransitive/EntityFramework.props",
  ///         "buildTransitive/EntityFramework.targets",
  ///         "buildTransitive/netcoreapp3.0/EntityFramework.props",
  ///         "buildTransitive/netcoreapp3.0/EntityFramework.targets",
  ///         "content/net40/App.config.install.xdt",
  ///         "content/net40/App.config.transform",
  ///         "content/net40/Web.config.install.xdt",
  ///         "content/net40/Web.config.transform",
  ///         "entityframework.6.4.4.nupkg.sha512",
  ///         "entityframework.nuspec",
  ///         "lib/net40/EntityFramework.SqlServer.dll",
  ///         "lib/net40/EntityFramework.SqlServer.xml",
  ///         "lib/net40/EntityFramework.dll",
  ///         "lib/net40/EntityFramework.xml",
  ///         "lib/net45/EntityFramework.SqlServer.dll",
  ///         "lib/net45/EntityFramework.SqlServer.xml",
  ///         "lib/net45/EntityFramework.dll",
  ///         "lib/net45/EntityFramework.xml",
  ///         "lib/netstandard2.1/EntityFramework.SqlServer.dll",
  ///         "lib/netstandard2.1/EntityFramework.SqlServer.xml",
  ///         "lib/netstandard2.1/EntityFramework.dll",
  ///         "lib/netstandard2.1/EntityFramework.xml",
  ///         "tools/EntityFramework6.PS2.psd1",
  ///         "tools/EntityFramework6.PS2.psm1",
  ///         "tools/EntityFramework6.psd1",
  ///         "tools/EntityFramework6.psm1",
  ///         "tools/about_EntityFramework6.help.txt",
  ///         "tools/init.ps1",
  ///         "tools/install.ps1",
  ///         "tools/net40/any/ef6.exe",
  ///         "tools/net40/any/ef6.pdb",
  ///         "tools/net40/win-x86/ef6.exe",
  ///         "tools/net40/win-x86/ef6.pdb",
  ///         "tools/net45/any/ef6.exe",
  ///         "tools/net45/any/ef6.pdb",
  ///         "tools/net45/win-x86/ef6.exe",
  ///         "tools/net45/win-x86/ef6.pdb",
  ///         "tools/netcoreapp3.0/any/ef6.dll",
  ///         "tools/netcoreapp3.0/any/ef6.pdb",
  ///         "tools/netcoreapp3.0/any/ef6.runtimeconfig.json"
  ///       ]
  ///     },
  final Map<String, LibraryInfo> libraries;

  final Project project;

  CsProjectType get csProjectType {
    if (targets.any((x) => x.contains('.NETFramework'))) {
      return CsProjectType.netFramework;
    } else {
      return CsProjectType.netCore;
    }
  }

  const CsProjectAsset({
    required this.targets,
    required this.libraries,
    required this.project,
  });

  factory CsProjectAsset.fromJson(Map<String, dynamic> json) =>
      _$CsProjectAssetFromJson(json);
}

@JsonSerializable(
  createToJson: false,
)
class LibraryInfo {
  final String? sha512;

  final String? type;

  final String? path;

  const LibraryInfo({
    this.sha512,
    this.type,
    this.path,
  });

  factory LibraryInfo.fromJson(Map<String, dynamic> json) =>
      _$LibraryInfoFromJson(json);
}

@JsonSerializable(
  createToJson: false,
)
class Project {
  final Restore restore;

  const Project({
    required this.restore,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}

/// Restore properties in project.assets.json.
///
/// We can still work on even any of these properties missing.
@JsonSerializable(
  createToJson: false,
)
class Restore {
  final String? projectName;

  final String? projectPath;

  final String? packagesPath;

  final String? outputPath;

  final String? packageStyle;

  const Restore({
    this.projectName,
    this.projectPath,
    this.packagesPath,
    this.outputPath,
    this.packageStyle,
  });

  factory Restore.fromJson(Map<String, dynamic> json) =>
      _$RestoreFromJson(json);
}
