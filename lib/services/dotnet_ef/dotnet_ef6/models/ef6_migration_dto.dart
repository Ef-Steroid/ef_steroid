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
