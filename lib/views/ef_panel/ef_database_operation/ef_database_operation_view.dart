import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_database_operation/ef_database_operation_view_model.dart';
import 'package:fast_dotnet_ef/views/widgets/loading_widget.dart';
import 'package:fast_dotnet_ef/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
        return Column(
          children: [
            if (vm.showListMigrationBanner)
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  color: Colors.amberAccent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                      icon: const Icon(Icons.refresh),
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
        );
      },
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
    return LoadingWidget(
      isBusy: widget.vm.isBusy,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            sortAscending: widget.vm.sortMigrationAscending,
            sortColumnIndex: 0,
            columns: <DataColumn>[
              DataColumn(
                label: Text(l('Migration')),
                onSort: (value, ascending) {
                  widget.vm.sortMigrationAscending = ascending;
                },
              ),
              DataColumn(
                label: Text(l('Applied')),
              ),
              DataColumn(
                label: Text(l('Operations')),
              ),
            ],
            rows: widget.vm.migrationHistories
                .map((migrationHistory) => DataRow(
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
                                  widget.vm.updateDatabaseToTargetedMigrationAsync(
                                    migrationHistory: migrationHistory,
                                  );
                                },
                                icon: const Icon(
                                  Icons.menu_open,
                                ),
                                tooltip: l('UpdateDatabaseToHere'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ))
                .toList(growable: false),
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
