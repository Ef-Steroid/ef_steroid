import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/shared/project_ef_type.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_core_operation/ef_core_operation_view_model.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view_model_data.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/widgets/add_migration_form.dart';
import 'package:ef_steroid/views/ef_panel/widgets/list_migration_banner.dart';
import 'package:ef_steroid/views/ef_panel/widgets/project_ef_type_toolbar.dart';
import 'package:ef_steroid/views/view_model_base.dart';
import 'package:ef_steroid/views/widgets/mvvm_binding_widget.dart';
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
  void initState() {
    super.initState();
    vm.initViewModelAsync(
      initParam: InitParam(
        param: EfOperationViewModelData(efPanelId: widget.efPanel.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return MVVMBindingWidget<EfCoreOperationViewModel>(
      viewModel: vm,
      builder: (context, vm, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _addMigrationAsync,
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
                  projectEfType: widget.efPanel.projectEfType,
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: EfOperationView(
                  vm: vm,
                  efPanel: widget.efPanel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onProjectEfTypeSaved(ProjectEfType value) {
    vm.switchEfProjectTypeAsync(efProjectType: value);
  }

  Future<void> _addMigrationAsync() {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => AddMigrationForm(
        vm: vm,
      ),
    );
  }
}
