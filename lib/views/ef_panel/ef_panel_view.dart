import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_database_operation/ef_database_operation_view.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation.dart';
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
        return SingleChildScrollView(
          child: ExpansionPanelList(
            expansionCallback: (index, isExpanded) {
              vm.setIsExpanded(
                index: index,
                isExpanded: !isExpanded,
              );
              setState(() {});
            },
            children: vm.efOperations.values
                .map((e) => ExpansionPanel(
                      isExpanded: e.isExpanded,
                      headerBuilder: (context, isExpanded) =>
                          Text(e.efOperation.toLocalizedString(context)),
                      body: _EfOperationPanel(
                        efOperation: e.efOperation,
                        efPanel: widget.efPanel,
                      ),
                    ))
                .toList(growable: false),
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
