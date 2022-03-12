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

import 'package:json_annotation/json_annotation.dart';

part 'ef6_migration_dto.g.dart';

/// Contains the path to the respective generated files.
@JsonSerializable()
class Ef6MigrationDto {
  /// The migration Id (a.k.a the migration name provided by the user).
  ///
  /// E.g. 202201150842177_InitialMigration.cs
  final String migration;

  /// The migration resource file.
  ///
  /// E.g. 202201150842177_InitialMigration.resx
  final String migrationResources;

  /// The migration designer file.
  ///
  /// E.g. 202201150842177_InitialMigration.Designer.cs
  final String migrationDesigner;

  Ef6MigrationDto({
    required this.migration,
    required this.migrationResources,
    required this.migrationDesigner,
  });

  factory Ef6MigrationDto.fromJson(Map<String, dynamic> json) =>
      _$Ef6MigrationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$Ef6MigrationDtoToJson(this);
}
