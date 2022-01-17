import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/shared/project_ef_type.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef6_operation/ef6_operation_view_model.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef_operation_view.dart';
import 'package:fast_dotnet_ef/views/ef_panel/widgets/list_migration_banner.dart';
import 'package:fast_dotnet_ef/views/ef_panel/widgets/project_ef_type_toolbar.dart';
import 'package:fast_dotnet_ef/views/widgets/mvvm_binding_widget.dart';
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
    final l = AL.of(context).text;
    return MVVMBindingWidget<Ef6OperationViewModel>(
      viewModel: vm,
      builder: (context, vm, child) {
        final configFileUri = vm.efPanel.configFileUri;
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: /*_addMigrationAsync*/ () {},
            label: Text(l('AddMigration')),
            icon: const Icon(Icons.add),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (vm.showListMigrationBanner)
                ListMigrationBanner(
                  onIgnorePressed: vm.hideListMigrationBanner,
                ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ProjectEfTypeToolbar(
                  onProjectEfTypeSaved: _onProjectEfTypeSaved,
                  projectEfType: vm.efPanel.projectEfType,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    '${l('ConfigFile')} $configFileUri',
                  ),
                  IconButton(
                    onPressed: vm.updateConfigFile,
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
              if (configFileUri != null) ...[
                const SizedBox(height: 8.0),
                Expanded(
                  child: EfOperationView(
                    vm: vm,
                    efPanel: widget.efPanel,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _onProjectEfTypeSaved(ProjectEfType value) {
    vm.switchEfProjectTypeAsync(efProjectType: value);
  }
}
