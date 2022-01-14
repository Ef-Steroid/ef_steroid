import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef6_operation/ef6_operation_view_model.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef_operation_view.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Ef6OperationView extends StatefulWidget {
  final EfPanel efPanel;

  const Ef6OperationView({
    Key? key,
    required this.efPanel,
  }) : super(key: key);

  @override
  _Ef6OperationViewState createState() => _Ef6OperationViewState();
}

class _Ef6OperationViewState extends State<Ef6OperationView> {
  final Ef6OperationViewModel vm = GetIt.I<Ef6OperationViewModel>();

  @override
  Widget build(BuildContext context) {
    return EfOperationView(
      vm: vm,
      efPanel: widget.efPanel,
    );
  }
}
