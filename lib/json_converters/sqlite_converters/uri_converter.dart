import 'package:json_annotation/json_annotation.dart';

class UriConverter implements JsonConverter<Uri, String> {
  const UriConverter();

  @override
  Uri fromJson(String json) {
    return Uri.parse(json);
  }

  @override
  String toJson(Uri object) {
    return object.path;
  }
}

class UriNullableConverter implements JsonConverter<Uri?, String?> {
  const UriNullableConverter();

  @override
  Uri? fromJson(String? json) {
    return json == null ? null : Uri.parse(json);
  }

  @override
  String? toJson(Uri? object) {
    return object?.path;
  }
}
