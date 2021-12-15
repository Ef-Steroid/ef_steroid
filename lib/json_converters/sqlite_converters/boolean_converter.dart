import 'package:json_annotation/json_annotation.dart';

class BooleanConverter implements JsonConverter<bool, int> {
  const BooleanConverter();

  @override
  bool fromJson(int json) => json == 1 ? true : false;

  @override
  int toJson(bool object) => object ? 1 : 0;
}
