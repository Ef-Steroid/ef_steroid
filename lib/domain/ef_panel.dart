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

  /// The config file path selected for the EF Panel previously.
  ///
  /// We use this to store the user's configuration.
  final Uri? configFileUrl;

  EfPanel({
    int? id,
    required this.directoryUrl,
    this.configFileUrl,
  }) : super(id: id);

  factory EfPanel.fromJson(Map<String, dynamic> json) =>
      _$EfPanelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EfPanelToJson(this);

  EfPanel copyWith({
    int? id,
    Uri? directoryUrl,
    Uri? configFileUrl,
  }) {
    return EfPanel(
      id: id ?? this.id,
      directoryUrl: directoryUrl ?? this.directoryUrl,
      configFileUrl: configFileUrl ?? this.configFileUrl,
    );
  }
}
