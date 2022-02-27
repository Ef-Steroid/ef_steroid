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
