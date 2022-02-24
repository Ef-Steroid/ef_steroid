import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/repository_cache/repository_cache.dart';
import 'package:ef_steroid/shared/project_ef_type.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef6_operation/ef6_operation_view_model.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view_model_data.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/widgets/add_migration_form.dart';
import 'package:ef_steroid/views/ef_panel/widgets/list_migration_banner.dart';
import 'package:ef_steroid/views/ef_panel/widgets/project_ef_type_toolbar.dart';
import 'package:ef_steroid/views/view_model_base.dart';
import 'package:ef_steroid/views/widgets/mvvm_binding_widget.dart';
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

  final RepositoryCache<EfPanel> _efPanelRepositoryCache =
      GetIt.I<RepositoryCache<EfPanel>>();

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
    return MVVMBindingWidget<Ef6OperationViewModel>(
      viewModel: vm,
      builder: (context, vm, child) {
        return FutureBuilder<EfPanel?>(
          future: _efPanelRepositoryCache.getAsync(id: vm.efPanelId),
          builder: (context, snapshot) {
            final efPanel = snapshot.data;
            final configFileUri = efPanel?.configFileUri;
            final hasConfigFile = configFileUri != null;
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
                  if (efPanel != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ProjectEfTypeToolbar(
                      onProjectEfTypeSaved: _onProjectEfTypeSaved,
                      projectEfType: efPanel.projectEfType,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text.rich(
                      TextSpan(
                        text: l('ConfigFile'),
                        children: <InlineSpan>[
                          if (hasConfigFile)
                            TextSpan(
                              text: configFileUri.toFilePath(),
                            )
                          else
                            TextSpan(
                              text: l('NoConfigFileSelected'),
                              style: const TextStyle(
                                color: ColorConst.dangerColor,
                              ),
                            ),
                          WidgetSpan(
                            child: IconButton(
                              onPressed: vm.updateConfigFile,
                              icon: const Icon(
                                Icons.edit,
                                color: ColorConst.primaryColor,
                              ),
                            ),
                            alignment: PlaceholderAlignment.middle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hasConfigFile && efPanel != null) ...[
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: EfOperationView(
                        vm: vm,
                        efPanel: efPanel,
                      ),
                    ),
                  ] else
                    Center(
                      child: Text(l('PleaseSelectAConfigFileFirst')),
                    ),
                ],
              ),
            );
          },
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
