import 'package:json_annotation/json_annotation.dart';

part 'db_context.g.dart';

/// Define a DbContext information.
@JsonSerializable()
class DbContext {
  /// The db context full name.
  final String fullName;

  /// The db context safe name.
  ///
  /// We use this name for passing to `dotnet-ef`.
  final String safeName;

  /// The db context name.
  final String name;

  /// The db context assembly name.
  final String assemblyQualifiedName;

  DbContext({
    required this.fullName,
    required this.safeName,
    required this.name,
    required this.assemblyQualifiedName,
  });

  factory DbContext.fromJson(Map<String, dynamic> json) =>
      _$DbContextFromJson(json);

  Map<String, dynamic> toJson() => _$DbContextToJson(this);
}
