import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/helpers/uri_helper.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_database_operation/ef_database_operation_view_model.dart';
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
    vm.initViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return MVVMBindingWidget<EfDatabaseOperationViewModel>(
      viewModel: vm,
      builder: (context, vm, child) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 300,
          ),
          child: ListView.builder(
            itemBuilder: (context, index) {
              final migrationFile = vm.migrationFiles[index];
              return ListTile(
                title: Text(migrationFile.fileUri.toDecodedString()),
              );
            },
            itemCount: vm.migrationFiles.length,
          ),
        );
      },
    );
  }
}
