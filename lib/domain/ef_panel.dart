import 'package:fast_dotnet_ef/domain/entity_dto.dart';
import 'package:fast_dotnet_ef/shared/project_ef_type.dart';
import 'package:fast_dotnet_ef/util/reflector.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ef_panel.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.pascal,
)
@reflector
class EfPanel extends EntityDto {
  /// The directory url of the EF Panel.
  final Uri directoryUri;

  /// The config file path selected for the EF Panel previously.
  ///
  /// We use this to store the user's configuration.
  final Uri? configFileUri;

  /// The entity framework project type of this [EfPanel].
  @JsonKey(unknownEnumValue: ProjectEfType.defaultValue)
  final ProjectEfType? projectEfType;

  EfPanel({
    int? id,
    required this.directoryUri,
    this.configFileUri,
    this.projectEfType = ProjectEfType.defaultValue,
  }) : super(id: id);

  factory EfPanel.fromJson(Map<String, dynamic> json) =>
      _$EfPanelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EfPanelToJson(this);

  EfPanel copyWith({
    int? id,
    Uri? directoryUri,
    Uri? configFileUri,
    ProjectEfType? projectEfType,
  }) {
    return EfPanel(
      id: id ?? this.id,
      directoryUri: directoryUri ?? this.directoryUri,
      configFileUri: configFileUri ?? this.configFileUri,
      projectEfType: projectEfType ?? this.projectEfType,
    );
  }
}
