import 'package:json_annotation/json_annotation.dart';

part 'add_migration_dto.g.dart';

/// Contains the path to the respective generated files.
@JsonSerializable()
class AddMigrationDto {
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

  AddMigrationDto({
    required this.migration,
    required this.migrationResources,
    required this.migrationDesigner,
  });

  factory AddMigrationDto.fromJson(Map<String, dynamic> json) =>
      _$AddMigrationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AddMigrationDtoToJson(this);
}
