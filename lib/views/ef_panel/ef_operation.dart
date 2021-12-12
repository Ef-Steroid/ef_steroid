import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:flutter/material.dart';

enum EfOperation {
  database,
  migrations,
  script,
}

extension EfOperationExt on EfOperation {
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
