// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ef_panel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EfPanel _$EfPanelFromJson(Map<String, dynamic> json) => EfPanel(
      id: json['id'] as int?,
      directoryUrl: Uri.parse(json['directoryUrl'] as String),
    );

Map<String, dynamic> _$EfPanelToJson(EfPanel instance) => <String, dynamic>{
      'id': instance.id,
      'directoryUrl': instance.directoryUrl.toString(),
    };
