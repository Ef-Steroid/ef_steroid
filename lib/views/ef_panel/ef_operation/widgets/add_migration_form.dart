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

import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/shared/project_ef_type.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view_model_base.dart';
import 'package:ef_steroid/views/widgets/form_fields/custom_text_form_field.dart';
import 'package:ef_steroid/views/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiver/strings.dart';

class AddMigrationForm extends StatefulWidget {
  final EfOperationViewModelBase vm;

  const AddMigrationForm({
    Key? key,
    required this.vm,
  }) : super(key: key);

  @override
  _AddMigrationFormState createState() => _AddMigrationFormState();
}

class _AddMigrationFormState extends State<AddMigrationForm> {
  bool _isBusy = false;

  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  final FocusNode _migrationFieldFocusNode = FocusNode(
    debugLabel: 'Migration Field',
  );
  final FocusNode _addMigrationButtonFocusNode = FocusNode(
    debugLabel: 'Add Migration Button',
  );
  final FocusNode _cancelButtonFocusNode = FocusNode(
    debugLabel: 'Cancel Button',
  );
  final FocusNode _forceCheckboxFocusNode = FocusNode(
    debugLabel: 'Force Checkbox',
  );
  final FocusNode _ignoreChangesCheckboxFocusNode = FocusNode(
    debugLabel: 'Ignore Changes Checkbox',
  );

  @override
  void dispose() {
    _migrationFieldFocusNode.dispose();
    _addMigrationButtonFocusNode.dispose();
    _cancelButtonFocusNode.dispose();
    _forceCheckboxFocusNode.dispose();
    _ignoreChangesCheckboxFocusNode.dispose();
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final form = vm.form;
    final l = AL.of(context).text;

    final efPanel = vm.efPanel;
    return LoadingWidget(
      isBusy: _isBusy,
      child: Dialog(
        insetPadding: const EdgeInsets.all(40.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: FocusScope(
            node: _focusScopeNode,
            onKeyEvent: _onKeyEvent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: form.formKey,
                  child: CustomTextFormField(
                    focusNode: _migrationFieldFocusNode,
                    formField: form.migrationFormField,
                    autofocus: true,
                    inputDecoration: InputDecoration(
                      label: Text.rich(
                        TextSpan(
                          text: l('MigrationName'),
                          children: const [
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: ColorConst.dangerColor),
                            )
                          ],
                        ),
                      ),
                      hintText: l('EnterMigrationName'),
                    ),
                    validator: (value) {
                      if (isBlank(value)) {
                        return vm.getDefaultFormExceptionMessage();
                      }
                      return null;
                    },
                  ),
                ),
                if (efPanel?.projectEfType == ProjectEfType.ef6) ...[
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: form.forceFormField.valueNotifier.value,
                    focusNode: _forceCheckboxFocusNode,
                    title: const Text('Force'),
                    onChanged: (value) {
                      form.forceFormField.valueNotifier.value = value!;
                      setState(() {});
                    },
                  ),
                  CheckboxListTile(
                    value: form.ignoreChangesFormField.valueNotifier.value,
                    focusNode: _ignoreChangesCheckboxFocusNode,
                    title: const Text('Ignore Changes'),
                    onChanged: (value) {
                      form.ignoreChangesFormField.valueNotifier.value = value!;
                      setState(() {});
                    },
                  ),
                ],
                const SizedBox(height: 16),
                ButtonBar(
                  children: <Widget>[
                    OutlinedButton(
                      focusNode: _cancelButtonFocusNode,
                      onPressed: _onCancelButtonPressed,
                      child: Text(l('Cancel')),
                    ),
                    OutlinedButton(
                      focusNode: _addMigrationButtonFocusNode,
                      onPressed: _onAddMigrationPressedAsync,
                      child: Text(l('AddMigration')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onAddMigrationPressedAsync() async {
    _isBusy = true;
    setState(() {});
    await widget.vm.addMigrationAsync();
    _isBusy = false;
    setState(() {});
  }

  void _onCancelButtonPressed() {
    Navigator.pop(context);
  }

  KeyEventResult _onKeyEvent(
    FocusNode node,
    KeyEvent event,
  ) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _onCancelButtonPressed();
      return KeyEventResult.handled;
    }

    if (_focusScopeNode.focusedChild != _migrationFieldFocusNode) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      _onAddMigrationPressedAsync();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
