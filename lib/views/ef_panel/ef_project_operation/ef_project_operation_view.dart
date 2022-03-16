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

import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/repository_cache/repository_cache.dart';
import 'package:ef_steroid/shared/project_ef_type.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef6_operation/ef6_operation_view.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_core_operation/ef_core_operation_view.dart';
import 'package:ef_steroid/views/ef_panel/ef_project_operation/ef_project_operation_view_model.dart';
import 'package:ef_steroid/views/ef_panel/ef_project_operation/ef_project_operation_view_model_data.dart';
import 'package:ef_steroid/views/ef_panel/widgets/project_ef_type_toolbar.dart';
import 'package:ef_steroid/views/view_model_base.dart';
import 'package:ef_steroid/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class EfProjectOperationView extends StatefulWidget {
  final int efPanelId;

  const EfProjectOperationView({
    Key? key,
    required this.efPanelId,
  }) : super(key: key);

  @override
  _EfProjectOperationViewState createState() => _EfProjectOperationViewState();
}

class _EfProjectOperationViewState extends State<EfProjectOperationView> {
  final EfProjectOperationViewModel vm = GetIt.I<EfProjectOperationViewModel>();

  final RepositoryCache<EfPanel> _efPanelRepositoryCache =
      GetIt.I<RepositoryCache<EfPanel>>();

  @override
  void initState() {
    super.initState();
    vm.initViewModelAsync(
      initParam: InitParam(
        param: EfProjectOperationViewModelData(
          efPanelId: widget.efPanelId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MVVMBindingWidget<EfProjectOperationViewModel>(
      viewModel: vm,
      builder: (context, vm, child) {
        return FutureBuilder<EfPanel?>(
          future: _efPanelRepositoryCache.getAsync(id: widget.efPanelId),
          builder: (context, snapshot) {
            final efPanel = snapshot.data;
            if (efPanel == null) return const SizedBox.shrink();

            Widget widget;
            switch (efPanel.projectEfType) {
              case ProjectEfType.efCore:
                widget = EfCoreOperationView(efPanelId: efPanel.id!);
                break;
              case ProjectEfType.ef6:
                widget = Ef6OperationView(efPanel: efPanel);
                break;
              case null:
              case ProjectEfType.defaultValue:
                widget = _EfProjectTypeSelector(
                  vm: vm,
                );
                break;
            }

            return widget;
          },
        );
      },
    );
  }
}

class _EfProjectTypeSelector extends StatefulWidget {
  final EfProjectOperationViewModel vm;

  const _EfProjectTypeSelector({
    Key? key,
    required this.vm,
  }) : super(key: key);

  @override
  _EfProjectTypeSelectorState createState() => _EfProjectTypeSelectorState();
}

class _EfProjectTypeSelectorState extends State<_EfProjectTypeSelector> {
  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l('UnableToIdentifyProjectEfType'),
            style: const TextStyle(color: ColorConst.dangerColor),
          ),
          ProjectEfTypeToolbar(
            onProjectEfTypeSaved: _onProjectEfTypeSaved,
          ),
        ],
      ),
    );
  }

  void _onProjectEfTypeSaved(ProjectEfType value) {
    widget.vm.switchEfProjectTypeAsync(projectEfType: value);
  }
}
