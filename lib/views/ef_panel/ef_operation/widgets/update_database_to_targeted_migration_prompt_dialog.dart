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

import 'package:ef_steroid/localization/localizations.dart';
import 'package:flutter/material.dart';

class UpdateDatabaseToTargetedMigrationPromptDialogResult {
  /// Indicate that the users wants to execute the migration with --force.
  final bool runWithForce;

  /// Indicate that the user wants to proceed with the execution.
  final bool accepted;

  UpdateDatabaseToTargetedMigrationPromptDialogResult({
    required this.runWithForce,
    required this.accepted,
  });
}

class UpdateDatabaseToTargetedMigrationPromptDialog extends StatefulWidget {
  /// Indicate if [UpdateDatabaseToTargetedMigrationPromptDialog] needs to show
  /// a [CheckboxListTile] for executing the migration with --force.
  final bool showForceMigration;

  /// Indicate if the user wants to revert all the migrations.
  final bool isRevertingAllMigrations;

  const UpdateDatabaseToTargetedMigrationPromptDialog({
    Key? key,
    required this.showForceMigration,
    required this.isRevertingAllMigrations,
  }) : super(key: key);

  @override
  State<UpdateDatabaseToTargetedMigrationPromptDialog> createState() =>
      _UpdateDatabaseToTargetedMigrationPromptDialogState();
}

class _UpdateDatabaseToTargetedMigrationPromptDialogState
    extends State<UpdateDatabaseToTargetedMigrationPromptDialog> {
  bool _runWithForce = false;

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      title: Text(
        widget.isRevertingAllMigrations
            ? l('RevertAllMigrationsPrompt')
            : l('UpdateDatabaseToTargetedMigrationPrompt'),
      ),
      content: widget.showForceMigration
          ? CheckboxListTile(
              title: Text(l('RunWithForce')),
              value: _runWithForce,
              onChanged: (bool? value) {
                _runWithForce = value!;
                setState(() {});
              },
            )
          : null,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              UpdateDatabaseToTargetedMigrationPromptDialogResult(
                runWithForce: _runWithForce,
                accepted: false,
              ),
            );
          },
          child: Text(l('Cancel')),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              UpdateDatabaseToTargetedMigrationPromptDialogResult(
                runWithForce: _runWithForce,
                accepted: true,
              ),
            );
          },
          child: Text(l('OK')),
        ),
      ],
    );
  }
}
