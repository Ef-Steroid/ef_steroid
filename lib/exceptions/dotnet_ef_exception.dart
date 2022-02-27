/*
 * Copyright 2022-2022 MOK KAH WAI and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

enum DotnetEfExceptionType {
  unknown,
  removeMigration,
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
      case DotnetEfExceptionType.unknown:
      case DotnetEfExceptionType.removeMigration:
        return _parseGeneralErrorMessage();
    }
  }

  String _parseGeneralErrorMessage() {
    return errorMessage ?? '';
  }
}

class UnknownDotnetEfException extends DotnetEfException {
  static final RegExp _multipleContextsErrorRegex = RegExp(
    'More than one DbContext was found. Specify which one to use. Use the \'-Context\' parameter for PowerShell commands and the \'--context\' parameter for dotnet commands.',
  );

  bool get isMultipleContextsError =>
      _multipleContextsErrorRegex.hasMatch(errorMessage ?? '');

  UnknownDotnetEfException({
    String? errorMessage,
  }) : super(
          dotnetEfExceptionType: DotnetEfExceptionType.unknown,
          errorMessage: errorMessage,
        );
}

class RemoveMigrationDotnetEfException extends DotnetEfException {
  /// Error message can be found [here](https://github.com/dotnet/efcore/blob/d5cac5b2fb6fe21459323dbdbce77ba32d2c991d/src/EFCore.Design/Properties/DesignStrings.resx?_pjax=%23js-repo-pjax-container%2C%20div%5Bitemtype%3D%22http%3A%2F%2Fschema.org%2FSoftwareSourceCode%22%5D%20main%2C%20%5Bdata-pjax-container%5D#L362).
  static final RegExp _migrationAppliedErrorRegex = RegExp(
    'The migration \'.+\' has already been applied to the database. Revert it and try again. If the migration has been applied to other databases, consider reverting its changes using a new migration instead.',
  );

  /// Indicate if the error message from EFCore means that the migration is
  /// applied.
  bool get isMigrationAppliedError =>
      _migrationAppliedErrorRegex.hasMatch(errorMessage ?? '');

  RemoveMigrationDotnetEfException({
    String? errorMessage,
  }) : super(
          dotnetEfExceptionType: DotnetEfExceptionType.removeMigration,
          errorMessage: errorMessage,
        );
}
