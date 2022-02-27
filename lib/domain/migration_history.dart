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

import 'package:ef_steroid/json_converters/boolean_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'migration_history.g.dart';

/// The migration history from running:
///
/// `dotnet-ef migrations list`
/// ```json
/// {
///  "id": "20211210144842_InitialMigration",
///  "name": "InitialMigration",
///  "safeName": "InitialMigration",
///  "applied": true
/// }
/// ```
@JsonSerializable()
class MigrationHistory {
  /// A combination of timestamp and migration name.
  final String id;

  final String name;

  final String safeName;

  @NullableBooleanConverter()
  final bool applied;

  /// Compute if this migration history is ancient, for reverting all migrations
  /// purpose.
  bool get isAncient => id == '0';

  const MigrationHistory({
    required this.id,
    required this.name,
    required this.safeName,
    required this.applied,
  });

  MigrationHistory.ef6({
    required this.id,
    required this.applied,
  })  : name = '',
        safeName = '';

  /// Migration history for reverting all migrations.
  const MigrationHistory.ancient()
      : id = '0',
        name = '',
        safeName = '',
        applied = true;

  factory MigrationHistory.fromJson(Map<String, dynamic> json) =>
      _$MigrationHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$MigrationHistoryToJson(this);
}
