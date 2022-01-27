import 'package:fast_dotnet_ef/helpers/theme_helper.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/shared/project_ef_type.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef6_operation/ef6_operation_view.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef_core_operation/ef_core_operation_view.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_project_operation/ef_project_operation_view_model.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_project_operation/ef_project_operation_view_model_data.dart';
import 'package:fast_dotnet_ef/views/ef_panel/widgets/project_ef_type_toolbar.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';
import 'package:fast_dotnet_ef/views/widgets/mvvm_binding_widget.dart';
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
        return FutureBuilder(
          future: vm.projectTypeDetectionCompleter.future,
          builder: (context, snapshotData) {
            final efPanel = vm.efPanel;
            if (efPanel == null) return const SizedBox.shrink();

            Widget widget;
            switch (efPanel.projectEfType) {
              case ProjectEfType.efCore:
                widget = EfCoreOperationView(efPanel: efPanel);
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

            return EfProjectOperation(
              efProjectOperationViewModel: vm,
              child: widget,
            );
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

class EfProjectOperation extends InheritedWidget {
  @protected
  final EfProjectOperationViewModel efProjectOperationViewModel;

  const EfProjectOperation({
    Key? key,
    required this.efProjectOperationViewModel,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(covariant EfProjectOperation oldWidget) {
    return oldWidget.efProjectOperationViewModel != efProjectOperationViewModel;
  }

  static EfProjectOperation? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EfProjectOperation>();

  Future<void> refreshEfPanelAsync() =>
      efProjectOperationViewModel.fetchEfPanelAsync();
}
