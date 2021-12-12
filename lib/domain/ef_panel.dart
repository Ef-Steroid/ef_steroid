import 'package:fast_dotnet_ef/domain/entity_dto.dart';
import 'package:fast_dotnet_ef/json_converters/sqlite_converters/boolean_converter.dart';
import 'package:fast_dotnet_ef/util/reflector.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ef_panel.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.pascal,
)
@reflector
class EfPanel extends EntityDto {
  @override
  String get tableName => 'EfPanels';

  /// The directory url of the EF Panel.
  final Uri directoryUrl;

  /// Indicate if the data
  @BooleanConverter()
  final bool isUpdateDatabaseSectionExpanded;

  EfPanel({
    int? id,
    required this.directoryUrl,
    this.isUpdateDatabaseSectionExpanded = false,
  }) : super(id: id);

  factory EfPanel.fromJson(Map<String, dynamic> json) =>
      _$EfPanelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EfPanelToJson(this);

  EfPanel copyWith({
    int? id,
    Uri? directoryUrl,
    bool? isUpdateDatabaseSectionExpanded,
  }) {
    return EfPanel(
      id: id ?? this.id,
      directoryUrl: directoryUrl ?? this.directoryUrl,
      isUpdateDatabaseSectionExpanded: isUpdateDatabaseSectionExpanded ??
          this.isUpdateDatabaseSectionExpanded,
    );
  }
}
