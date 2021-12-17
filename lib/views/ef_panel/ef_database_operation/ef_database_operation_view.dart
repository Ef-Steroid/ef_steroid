import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/helpers/theme_helper.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_database_operation/ef_database_operation_view_model.dart';
import 'package:fast_dotnet_ef/views/widgets/form_fields/custom_text_form_field.dart';
import 'package:fast_dotnet_ef/views/widgets/loading_widget.dart';
import 'package:fast_dotnet_ef/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:quiver/strings.dart';

class EfDatabaseOperationView extends StatefulWidget {
  final EfPanel efPanel;

  const EfDatabaseOperationView({
    Key? key,
    required this.efPanel,
  }) : super(key: key);

  @override
  _EfDatabaseOperationViewState createState() =>
      _EfDatabaseOperationViewState();
}

class _EfDatabaseOperationViewState extends State<EfDatabaseOperationView> {
  final EfDatabaseOperationViewModel vm =
      GetIt.I<EfDatabaseOperationViewModel>();

  @override
  void initState() {
    super.initState();
    vm.efPanel = widget.efPanel;
    vm.initViewModelAsync();
  }

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return MVVMBindingWidget<EfDatabaseOperationViewModel>(
      viewModel: vm,
      builder: (context, vm, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _addMigrationAsync,
            label: Text(l('AddMigration')),
            icon: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              if (vm.showListMigrationBanner)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: ColorConst.warningColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l('RefreshMigrationIndicator'),
                        maxLines: 2,
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: vm.hideListMigrationBanner,
                        child: Text(
                          l('Ignore'),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
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
              ),
              Expanded(
                child: _MigrationsTable(vm: vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addMigrationAsync() {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          _AddMigrationForm(
        vm: vm,
      ),
    );
  }
}

class _MigrationsTable extends StatefulWidget {
  final EfDatabaseOperationViewModel vm;

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
                            onPressed: vm.removeMigrationAsync,
                            icon: const Icon(Icons.remove),
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
  final EfDatabaseOperationViewModel vm;

  const _AddMigrationForm({
    Key? key,
    required this.vm,
  }) : super(key: key);

  @override
  _AddMigrationFormState createState() => _AddMigrationFormState();
}

class _AddMigrationFormState extends State<_AddMigrationForm> {
  bool _isBusy = false;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: form.formKey,
                child: CustomTextFormField(
                  formField: form.migrationFormField,
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
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: _onAddMigrationPressedAsync,
                  child: Text(l('AddMigration')),
                ),
              ),
            ],
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
}
