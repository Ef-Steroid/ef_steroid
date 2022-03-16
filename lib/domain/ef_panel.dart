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

import 'package:ef_steroid/domain/entity_dto.dart';
import 'package:ef_steroid/shared/project_ef_type.dart';
import 'package:ef_steroid/util/reflector.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ef_panel.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.pascal,
)
@reflector
class EfPanel extends EntityDto {
  /// The directory url of the EF Panel.
  // @UriConverter()
  final Uri directoryUri;

  /// The config file path selected for the EF Panel previously.
  ///
  /// We use this to store the user's configuration.
  // @UriNullableConverter()
  final Uri? configFileUri;

  /// The entity framework project type of this [EfPanel].
  @JsonKey(unknownEnumValue: ProjectEfType.defaultValue)
  final ProjectEfType? projectEfType;

  /// The DbContext name.
  final String? dbContextName;

  EfPanel({
    int? id,
    required this.directoryUri,
    this.configFileUri,
    this.projectEfType = ProjectEfType.defaultValue,
    this.dbContextName,
  }) : super(id: id);

  factory EfPanel.fromJson(Map<String, dynamic> json) =>
      _$EfPanelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EfPanelToJson(this);

  EfPanel copyWith({
    int? id,
    Uri? directoryUri,
    Uri? configFileUri,
    ProjectEfType? projectEfType,
    String? dbContextName,
  }) {
    return EfPanel(
      id: id ?? this.id,
      directoryUri: directoryUri ?? this.directoryUri,
      configFileUri: configFileUri ?? this.configFileUri,
      projectEfType: projectEfType ?? this.projectEfType,
      dbContextName: dbContextName ?? this.dbContextName,
    );
  }
}
