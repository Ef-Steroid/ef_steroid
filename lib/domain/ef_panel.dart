import 'package:fast_dotnet_ef/data/default_values.dart';
import 'package:fast_dotnet_ef/domain/entity_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ef_panel.g.dart';

@JsonSerializable()
class EfPanel extends EntityDto {
  static const String tableName = 'EfPanels';

  /// The directory url of the EF Panel.
  final Uri directoryUrl;

  EfPanel({
    int? id,
    required this.directoryUrl,
  }) : super(id: id);

  factory EfPanel.fromJson(Map<String, dynamic> json) =>
      _$EfPanelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EfPanelToJson(this);
}
