/*
 * Copyright 2022-2022 MOK KAH WAI and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
  final int efPanelId;

  const EfCoreOperationView({
    Key? key,
    required this.efPanelId,
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
        param: EfOperationViewModelData(efPanelId: widget.efPanelId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return MVVMBindingWidget<EfCoreOperationViewModel>(
      viewModel: vm,
      builder: (context, vm, child) {
        final efPanel = vm.efPanel;
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
                  projectEfType: efPanel?.projectEfType,
                ),
              ),
              const SizedBox(height: 8.0),
              if (efPanel != null)
                Expanded(
                  child: EfOperationView(
                    vm: vm,
                    efPanelId: efPanel.id!,
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
