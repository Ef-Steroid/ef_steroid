import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:ef_steroid/views/ef_panel/ef_add_panel.dart';
import 'package:ef_steroid/views/ef_panel/ef_project_operation/ef_project_operation_view.dart';
import 'package:ef_steroid/views/ef_panel/tab_data_value.dart';
import 'package:ef_steroid/views/root_tab_view_model.dart';
import 'package:ef_steroid/views/view_model_base.dart';
import 'package:ef_steroid/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tabbed_view/tabbed_view.dart';

class RootTabView extends StatefulWidget {
  final TabbedViewController tabbedViewController;

  const RootTabView({
    Key? key,
    required this.tabbedViewController,
  }) : super(key: key);

  @override
  State<RootTabView> createState() => _RootTabViewState();
}

class _RootTabViewState extends State<RootTabView> {
  final RootTabViewModel vm = GetIt.I<RootTabViewModel>();

  @override
  void initState() {
    super.initState();
    vm.tabbedViewController = widget.tabbedViewController;
    vm.initViewModelAsync(
      initParam: const InitParam(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MVVMBindingWidget<RootTabViewModel>(
      viewModel: vm,
      builder: (context, vm, child) {
        return TabbedViewTheme(
          data: ThemeHelper.tabbedViewThemeData(context),
          child: TabbedView(
            controller: widget.tabbedViewController,
            onTabClose: _onTabClosedAsync,
            contentBuilder: (context, index) {
              final tabDataValue =
                  widget.tabbedViewController.tabs[index].value;
              if (tabDataValue is AddEfPanelTabDataValue) {
                return EfAddPanelView(
                  onAddProjectPressed: vm.addEfProjectAsync,
                );
              }

              if (tabDataValue is EfPanelTabDataValue) {
                return EfProjectOperationView(
                  efPanelId: tabDataValue.efPanel.id!,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Future<void> _onTabClosedAsync(int index, TabData tabData) {
    final tabValue = tabData.value;
    if (tabValue is! EfPanelTabDataValue) return Future.value();
    return vm.removeFromStorageAsync(efPanel: tabValue.efPanel);
  }
}
