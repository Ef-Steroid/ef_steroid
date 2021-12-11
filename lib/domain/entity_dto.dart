import 'package:fast_dotnet_ef/data/default_values.dart';

abstract class EntityDto {
  final int? id;

  bool get isTransient => id == null;

  EntityDto({
    this.id,
  });

  Map<String, dynamic> toJson();
}
