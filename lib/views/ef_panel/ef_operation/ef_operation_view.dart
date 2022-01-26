import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view_model_base.dart';
import 'package:ef_steroid/views/widgets/loading_widget.dart';
import 'package:ef_steroid/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';

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
                        if (vm.canShowRemoveMigrationButton(
                          migrationHistory: migrationHistory,
                        ))
                          IconButton(
                            onPressed: () {
                              vm.removeMigrationAsync(
                                force: false,
                                migrationHistory: migrationHistory,
                              );
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
