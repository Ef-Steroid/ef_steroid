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

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'db_context.g.dart';

/// Define a DbContext information.
@JsonSerializable()
class DbContext with EquatableMixin {
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

  /// Check if this object is dummy in the context of [ef_steroid].
  final bool isDummy;

  const DbContext({
    required String fullName,
    required String safeName,
    required String name,
    required String assemblyQualifiedName,
  }) : this._(
          fullName: fullName,
          safeName: safeName,
          name: name,
          assemblyQualifiedName: assemblyQualifiedName,
          isDummy: false,
        );

  const DbContext.dummy()
      : this._(
          fullName: '',
          safeName: '',
          name: '',
          assemblyQualifiedName: '',
          isDummy: true,
        );

  const DbContext._({
    required this.fullName,
    required this.safeName,
    required this.name,
    required this.assemblyQualifiedName,
    required this.isDummy,
  });

  factory DbContext.fromJson(Map<String, dynamic> json) =>
      _$DbContextFromJson(json);

  Map<String, dynamic> toJson() => _$DbContextToJson(this);

  @override
  List<Object?> get props => [
        fullName,
        safeName,
        name,
        assemblyQualifiedName,
        isDummy,
      ];
}

extension DbContextListExt on List<DbContext> {
  DbContext? findDbContextBySafeName(String? safeName) {
    if (safeName == null) {
      return null;
    }
    return firstWhereOrNull(
      (x) => x.safeName == safeName,
    );
  }
}
