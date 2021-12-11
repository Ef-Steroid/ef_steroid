// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ef_panel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EfPanel _$EfPanelFromJson(Map<String, dynamic> json) => EfPanel(
      id: json['Id'] as int?,
      directoryUrl: Uri.parse(json['DirectoryUrl'] as String),
    );

Map<String, dynamic> _$EfPanelToJson(EfPanel instance) => <String, dynamic>{
      'Id': instance.id,
      'DirectoryUrl': instance.directoryUrl.toString(),
    };
