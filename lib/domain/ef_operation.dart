import 'package:fast_dotnet_ef/helpers/icon_config.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

class _EfOperationValue {
  static const int database = 0;
  static const int migrations = 1;
  static const int script = 2;
}

enum EfOperation {
  @JsonValue(_EfOperationValue.database)
  database,
  @JsonValue(_EfOperationValue.migrations)
  migrations,
  @JsonValue(_EfOperationValue.script)
  script,
}

extension EfOperationExt on EfOperation {
  IconConfig toIconConfig() {
    switch (this) {
      case EfOperation.database:
        return const IconConfig(
          iconData: Icons.dns,
        );
      case EfOperation.migrations:
        return const IconConfig(
          iconData: Icons.account_tree,
        );
      case EfOperation.script:
        return const IconConfig(
          iconData: Icons.receipt_long,
        );
    }
  }

  String toLocalizedString(BuildContext context) {
    switch (this) {
      case EfOperation.database:
        return AL.of(context).text('Database');
      case EfOperation.migrations:
        return AL.of(context).text('Migrations');
      case EfOperation.script:
        return AL.of(context).text('Script');
    }
  }
}
