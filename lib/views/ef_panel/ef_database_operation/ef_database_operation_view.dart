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
    const boxDiameter = 24.0;
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l('RefreshMigrationIndicator'),
                      maxLines: 2,
                    ),
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
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(l('Refresh')),
                  onPressed: vm.listMigrationsAsync,
                ),
              ),
            ),
            LoadingWidget(
              isBusy: vm.isBusy,
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(l('Migration')),
                    ),
                    DataColumn(
                      label: Text(l('Applied')),
                    ),
                  ],
                  rows: vm.migrationHistories
                      .map((e) => DataRow(
                            cells: <DataCell>[
                              DataCell(
                                SelectableText(e.id),
                              ),
                              DataCell(
                                e.applied
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
                            ],
                          ))
                      .toList(growable: false),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
