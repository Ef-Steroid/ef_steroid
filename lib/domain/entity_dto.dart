abstract class EntityDto {
  final int? id;

  /// Check if this entity is transient (it's [id] is null).
  bool get isTransient => id == null;

  EntityDto({
    this.id,
  });

  Map<String, dynamic> toJson();

  Map<String, dynamic> toUpdateJson() => toJson()
    ..removeWhere(
      (key, value) => key == 'Id',
    );
}
