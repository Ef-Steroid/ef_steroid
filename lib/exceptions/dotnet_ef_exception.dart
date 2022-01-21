enum DotnetEfExceptionType {
  removeMigration,
  addMigration,
}

abstract class DotnetEfException implements Exception {
  final String? errorMessage;

  final DotnetEfExceptionType dotnetEfExceptionType;

  DotnetEfException({
    required this.dotnetEfExceptionType,
    required this.errorMessage,
  });

  @override
  String toString() {
    switch (dotnetEfExceptionType) {
      case DotnetEfExceptionType.removeMigration:
      case DotnetEfExceptionType.addMigration:
        return _parseGeneralErrorMessage();
    }
  }

  String _parseGeneralErrorMessage() {
    return errorMessage ?? '';
  }
}

class RemoveMigrationDotnetEfException extends DotnetEfException {
  /// Error message can be found [here](https://github.com/dotnet/efcore/blob/d5cac5b2fb6fe21459323dbdbce77ba32d2c991d/src/EFCore.Design/Properties/DesignStrings.resx?_pjax=%23js-repo-pjax-container%2C%20div%5Bitemtype%3D%22http%3A%2F%2Fschema.org%2FSoftwareSourceCode%22%5D%20main%2C%20%5Bdata-pjax-container%5D#L362).
  static final RegExp _migrationAppliedErrorRegex = RegExp(
    'The migration \'.+\' has already been applied to the database. Revert it and try again. If the migration has been applied to other databases, consider reverting its changes using a new migration instead.',
  );

  /// Indicate if the error message from EFCore means that the migration is
  /// applied.
  bool get isMigrationAppliedError {
    return _migrationAppliedErrorRegex.hasMatch(errorMessage ?? '');
  }

  RemoveMigrationDotnetEfException({
    String? errorMessage,
  }) : super(
          dotnetEfExceptionType: DotnetEfExceptionType.removeMigration,
          errorMessage: errorMessage,
        );
}

class AddMigrationDotnetEf6Exception extends DotnetEfException {
  AddMigrationDotnetEf6Exception({
    String? errorMessage,
  }) : super(
          dotnetEfExceptionType: DotnetEfExceptionType.addMigration,
          errorMessage: errorMessage,
        );
}
