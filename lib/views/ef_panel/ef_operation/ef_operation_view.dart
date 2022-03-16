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
import 'package:ef_steroid/views/ef_panel/ef_operation/ef6_operation/ef6_operation_view_model.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_core_operation/ef_core_operation_view_model.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view_model_base.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/widgets/db_context_selector.dart';
import 'package:ef_steroid/views/widgets/loading_widget.dart';
import 'package:ef_steroid/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';

class EfOperationView extends StatefulWidget {
  final EfOperationViewModelBase vm;

  final int efPanelId;

  const EfOperationView({
    Key? key,
    required this.efPanelId,
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
        final dbContextSelectorController = vm.dbContextSelectorController;
        return Builder(
          builder: (context) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      DbContextSelector(
                        vm: vm,
                        dbContextSelectorController:
                            dbContextSelectorController,
                      ),
                      const Spacer(),
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
                  child: _MigrationsTable(
                    vm: vm,
                    dbContextController: dbContextSelectorController,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MigrationsTable extends StatefulWidget {
  final EfOperationViewModelBase vm;

  final DbContextSelectorController dbContextController;

  const _MigrationsTable({
    Key? key,
    required this.vm,
    required this.dbContextController,
  }) : super(key: key);

  @override
  State<_MigrationsTable> createState() => _MigrationsTableState();
}

class _MigrationsTableState extends State<_MigrationsTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.dbContextController.addListener(_onDbContextChanged);
  }

  @override
  void didUpdateWidget(covariant _MigrationsTable oldWidget) {
    if (widget.dbContextController != oldWidget.dbContextController) {
      oldWidget.dbContextController.removeListener(_onDbContextChanged);
      widget.dbContextController.addListener(_onDbContextChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onDbContextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const boxDiameter = 24.0;
    final l = AL.of(context).text;
    final vm = widget.vm;
    final dbContext = widget.dbContextController.dbContext;
    final migrationHistories = vm.dbContextMigrationHistoriesMap[dbContext];
    return LoadingWidget(
      isBusy: vm.isBusy,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            sortAscending: vm.sortMigrationByAscending,
            sortColumnIndex: 0,
            columns: <DataColumn>[
              DataColumn(
                label: Text(l('Migration')),
                onSort: (value, ascending) {
                  vm.sortMigrationByAscending = ascending;
                },
              ),
              DataColumn(
                label: Text(l('Applied')),
              ),
              DataColumn(
                label: Text(l('Operations')),
              ),
            ],
            rows: migrationHistories?.map((migrationHistory) {
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
                              dbContext: dbContext,
                              migrationHistory: migrationHistory,
                            ))
                              IconButton(
                                onPressed: () {
                                  vm.removeMigrationAsync(
                                    force: false,
                                    migrationHistory: migrationHistory,
                                  );
                                },
                                icon: _RemoveMigrationIcon(vm: vm),
                                tooltip: l('RemoveMigration'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(growable: false) ??
                [],
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

class _RemoveMigrationIcon extends StatelessWidget {
  final EfOperationViewModelBase vm;

  const _RemoveMigrationIcon({
    Key? key,
    required this.vm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (vm is EfCoreOperationViewModel) {
      return const Icon(
        Icons.remove,
        color: ColorConst.dangerColor,
      );
    }

    if (vm is Ef6OperationViewModel) {
      return const Icon(
        Icons.delete,
        color: ColorConst.dangerColor,
      );
    }

    throw UnsupportedError(
      'Unsupported concrete EfOperationViewModelBase: ${vm.runtimeType}',
    );
  }
}
