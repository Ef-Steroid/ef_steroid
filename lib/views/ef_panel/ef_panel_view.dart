import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_database_operation/ef_database_operation_view.dart';
import 'package:fast_dotnet_ef/domain/ef_operation.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel_view_model.dart';
import 'package:fast_dotnet_ef/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class EfPanelView extends StatefulWidget {
  final EfPanel efPanel;

  const EfPanelView({
    Key? key,
    required this.efPanel,
  }) : super(key: key);

  @override
  State<EfPanelView> createState() => _EfPanelViewState();
}

class _EfPanelViewState extends State<EfPanelView> {
  final EfPanelViewModel vm = GetIt.I<EfPanelViewModel>();

  @override
  void initState() {
    super.initState();
    vm.efPanel = widget.efPanel;
    vm.initViewModelAsync();
  }

  @override
  Widget build(BuildContext context) {
    return MVVMBindingWidget<EfPanelViewModel>(
      viewModel: vm,
      builder: (context, vm, child) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                onDestinationSelected: (value) =>
                    vm.selectedEfOperation = EfOperation.values[value],
                labelType: NavigationRailLabelType.all,
                destinations: vm.efOperations.values
                    .map((x) => NavigationRailDestination(
                          icon: x.efOperation.toIconConfig().toIcon(),
                          label: Text(
                            x.efOperation.toLocalizedString(context),
                          ),
                        ))
                    .toList(growable: false),
                selectedIndex: vm.selectedEfOperation.index,
              ),
              Expanded(
                child: _EfOperationPanel(
                  efOperation: vm.selectedEfOperation,
                  efPanel: widget.efPanel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EfOperationPanel extends StatefulWidget {
  final EfOperation efOperation;
  final EfPanel efPanel;

  const _EfOperationPanel({
    Key? key,
    required this.efOperation,
    required this.efPanel,
  }) : super(key: key);

  @override
  State<_EfOperationPanel> createState() => _EfOperationPanelState();
}

class _EfOperationPanelState extends State<_EfOperationPanel> {
  @override
  Widget build(BuildContext context) {
    switch (widget.efOperation) {
      case EfOperation.database:
        return EfDatabaseOperationView(efPanel: widget.efPanel);
      case EfOperation.migrations:
        // TODO: Handle this case.
        break;
      case EfOperation.script:
        // TODO: Handle this case.
        break;
    }

    return Container();
  }
}
