import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef_core_operation/ef_core_operation_view_model.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef_operation_view.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';


class EfCoreOperationView extends StatefulWidget {
  final EfPanel efPanel;

  const EfCoreOperationView({
    Key? key,
    required this.efPanel,
  }) : super(key: key);

  @override
  State<EfCoreOperationView> createState() => _EfCoreOperationViewState();
}

class _EfCoreOperationViewState extends State<EfCoreOperationView> {
final EfCoreOperationViewModel vm = GetIt.I<EfCoreOperationViewModel>();

  @override
  Widget build(BuildContext context) {
    return EfOperationView(
      vm: vm,
      efPanel: widget.efPanel,
    );
  }
}
