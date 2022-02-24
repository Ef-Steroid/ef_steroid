import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/repository_cache/repository_cache.dart';
import 'package:ef_steroid/services/dotnet_ef/model/db_context.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef6_operation/ef6_operation_view_model.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view_model_base.dart';
import 'package:ef_steroid/views/widgets/loading_widget.dart';
import 'package:ef_steroid/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
                children: [
                  _DbContextSelector(vm: vm),
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
              child: _MigrationsTable(vm: vm),
            ),
          ],
        );
      },
    );
  }
}

class _DbContextSelector extends StatelessWidget {
  final EfOperationViewModelBase vm;
  final RepositoryCache<EfPanel> _efPanelRepositoryCache = GetIt.I<RepositoryCache<EfPanel>>();

  _DbContextSelector({
    Key? key,
    required this.vm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (vm is Ef6OperationViewModel) return const SizedBox.shrink();

    final l = AL.of(context).text;

    return FutureBuilder<EfPanel?>(
      future: _efPanelRepositoryCache.getAsync(id: vm.efPanelId),
      builder: (context, snapshot) {
        final efPanel = snapshot.data;
        if (efPanel == null) return const SizedBox.shrink();
        final dbContextName = efPanel.dbContextName;
        final dbContexts = vm.dbContexts;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(
                    color: ColorConst.primaryColor,
                    width: 1.0,
                  ),
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dbContextName,
                  onChanged: dbContexts.isEmpty ? null : _onDbContextChangedAsync,
                  items: dbContexts
                      .map(
                        (dbContext) => DropdownMenuItem<String>(
                          value: dbContext.safeName,
                          child: Text(
                            dbContext.safeName,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l('Refresh'),
              color: ColorConst.primaryColor,
              onPressed: vm.fetchDbContextsAsync,
            ),
          ],
        );
      },
    );
  }

  Future<void> _onDbContextChangedAsync(String? dbContextName) {
    if (dbContextName == null) {
      throw ArgumentError.notNull('dbContextName');
    }

    return vm.configureDbContextAsync(
      dbContext: vm.dbContexts.findDbContextBySafeName(dbContextName),
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
