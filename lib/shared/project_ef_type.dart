import 'package:json_annotation/json_annotation.dart';

class _ProjectEfTypeValue {
  static const int efCore = 0;
  static const int ef6 = 1;
  static const int defaultValue = -1;
}

enum ProjectEfType {
/// The entity framework project type.
  /// Entity framework Core.
  @JsonValue(_ProjectEfTypeValue.efCore)
  efCore,

  /// Entity framework 6.
  @JsonValue(_ProjectEfTypeValue.ef6)
  ef6,

  @JsonValue(_ProjectEfTypeValue.defaultValue)
  defaultValue,
}

extension EfProjectTypeExt on ProjectEfType {
  String toDisplayString() {
    switch (this) {
      case ProjectEfType.efCore:
        return 'Entity Framework Core';
      case ProjectEfType.ef6:
        return 'Entity Framework 6';
      case ProjectEfType.defaultValue:
        throw UnsupportedError('Unsupported EfProjectType: $this');
    }
  }
}
