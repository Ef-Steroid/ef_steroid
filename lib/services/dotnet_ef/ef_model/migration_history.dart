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
  final String id;

  final String name;

  final String safeName;

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
