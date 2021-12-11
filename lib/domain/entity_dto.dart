abstract class EntityDto {
  final int? id;

  String get tableName;

  /// Check if this entity is transient (it's [id] is null).
  bool get isTransient => id == null;

  EntityDto({
    this.id,
  });

  Map<String, dynamic> toJson();
}
