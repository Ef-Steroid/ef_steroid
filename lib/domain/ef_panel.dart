import 'package:fast_dotnet_ef/domain/ef_operation.dart';
import 'package:fast_dotnet_ef/domain/entity_dto.dart';
import 'package:fast_dotnet_ef/util/reflector.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ef_panel.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.pascal,
)
@reflector
class EfPanel extends EntityDto {
  /// The directory url of the EF Panel.
  final Uri directoryUrl;

  /// The selected ef operation.
  @JsonKey(
    unknownEnumValue: EfOperation.database,
  )
  final EfOperation selectedEfOperation;

  EfPanel({
    int? id,
    required this.directoryUrl,
    this.selectedEfOperation = EfOperation.database,
  }) : super(id: id);

  factory EfPanel.fromJson(Map<String, dynamic> json) =>
      _$EfPanelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EfPanelToJson(this);

  EfPanel copyWith({
    int? id,
    Uri? directoryUrl,
    EfOperation? selectedEfOperation,
  }) {
    return EfPanel(
      id: id ?? this.id,
      directoryUrl: directoryUrl ?? this.directoryUrl,
      selectedEfOperation: selectedEfOperation ?? this.selectedEfOperation,
    );
  }
}
