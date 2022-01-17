import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/helpers/theme_helper.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/shared/project_ef_type.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef_operation_view_model_base.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef_operation_view_model_data.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';
import 'package:fast_dotnet_ef/views/widgets/form_fields/custom_text_form_field.dart';
import 'package:fast_dotnet_ef/views/widgets/loading_widget.dart';
import 'package:fast_dotnet_ef/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiver/strings.dart';

class EfOperationView extends StatefulWidget {
  final EfOperationViewModelBase vm;

  final EfPanel efPanel;

  const EfOperationView({
    Key? key,
    required this.efPanel,
    required this.vm,
  }) : super(key: key);

  @override
  _EfOperationViewState createState() => _EfOperationViewState();
}

class _EfOperationViewState extends State<EfOperationView> {
  @override
  void initState() {
    super.initState();
    widget.vm.initViewModelAsync(
      initParam: InitParam(
        param: EfOperationViewModelData(efPanel: widget.efPanel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    final vm = widget.vm;

    return MVVMBindingWidget<EfOperationViewModelBase>(
      viewModel: vm,
      isReuse: true,
      builder: (context, vm, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.autorenew_outlined),
                    label: Text(l('RevertAllMigrations')),
                    onPressed: vm.revertAllMigrationsAsync,
                  ),
                  const SizedBox(width: 8.0),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text(l('Refresh')),
                    onPressed: vm.listMigrationsAsync,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _MigrationsTable(vm: vm),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addMigrationAsync() {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          _AddMigrationForm(
        vm: widget.vm,
      ),
    );
  }

  void _onProjectEfTypeSaved(ProjectEfType value) {
    widget.vm.switchEfProjectTypeAsync(efProjectType: value);
  }
}

class _MigrationsTable extends StatefulWidget {
  final EfOperationViewModelBase vm;

  const _MigrationsTable({
    Key? key,
    required this.vm,
  }) : super(key: key);

  @override
  State<_MigrationsTable> createState() => _MigrationsTableState();
}

class _MigrationsTableState extends State<_MigrationsTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    const boxDiameter = 24.0;
    final l = AL.of(context).text;
    final vm = widget.vm;
    return LoadingWidget(
      isBusy: vm.isBusy,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            sortAscending: vm.sortMigrationAscending,
            sortColumnIndex: 0,
            columns: <DataColumn>[
              DataColumn(
                label: Text(l('Migration')),
                onSort: (value, ascending) {
                  vm.sortMigrationAscending = ascending;
                },
              ),
              DataColumn(
                label: Text(l('Applied')),
              ),
              DataColumn(
                label: Text(l('Operations')),
              ),
            ],
            rows: vm.migrationHistories.map((migrationHistory) {
              return DataRow(
                cells: <DataCell>[
                  DataCell(
                    SelectableText(migrationHistory.id),
                  ),
                  DataCell(
                    migrationHistory.applied
                        ? const SizedBox.square(
                            dimension: boxDiameter,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                            ),
                          )
                        : const SizedBox.square(
                            dimension: boxDiameter,
                          ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            vm.updateDatabaseToTargetedMigrationAsync(
                              migrationHistory: migrationHistory,
                            );
                          },
                          icon: const Icon(
                            Icons.menu_open,
                          ),
                          tooltip: l('UpdateDatabaseToHere'),
                        ),
                        if ((vm.sortMigrationAscending
                                ? vm.migrationHistories.last.id
                                : vm.migrationHistories.first.id) ==
                            migrationHistory.id)
                          IconButton(
                            onPressed: () {
                              vm.removeMigrationAsync(force: false);
                            },
                            icon: const Icon(
                              Icons.remove,
                              color: ColorConst.dangerColor,
                            ),
                            tooltip: l('RemoveMigration'),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(growable: false),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _AddMigrationForm extends StatefulWidget {
  final EfOperationViewModelBase vm;

  const _AddMigrationForm({
    Key? key,
    required this.vm,
  }) : super(key: key);

  @override
  _AddMigrationFormState createState() => _AddMigrationFormState();
}

class _AddMigrationFormState extends State<_AddMigrationForm> {
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

  @override
  void dispose() {
    _migrationFieldFocusNode.dispose();
    _addMigrationButtonFocusNode.dispose();
    _cancelButtonFocusNode.dispose();
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final form = vm.form;
    final l = AL.of(context).text;
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
                    },
                  ),
                ),
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
