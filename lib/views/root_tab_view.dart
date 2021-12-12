import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/helpers/list_helpers.dart';
import 'package:fast_dotnet_ef/repository/repository.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_add_panel.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel_tab_data.dart';
import 'package:fast_dotnet_ef/views/ef_panel/tab_data_value.dart';
import 'package:file_picker/file_picker.dart';
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
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();

  @override
  void initState() {
    super.initState();
    _loadPreviousTabsAsync();
  }

  @override
  void reassemble() {
    _loadPreviousTabsAsync();
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return TabbedView(
      controller: widget.tabbedViewController,
      onTabClose: _onTabClosedAsync,
      contentBuilder: (context, index) {
        final tabDataValue = widget.tabbedViewController.tabs[index].value;
        if (tabDataValue is AddEfPanelTabDataValue) {
          return EfAddPanelView(
            onAddProjectPressed: _addEfProjectAsync,
          );
        }

        if (tabDataValue is EfPanelTabDataValue) {
          return EfPanelView(
            fileUri: tabDataValue.efPanel.directoryUrl,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _onTabClosedAsync(int index, TabData tabData) {
    final tabValue = tabData.value;
    if (tabValue is! EfPanelTabDataValue) return Future.value();
    return _removeFromStorageAsync(efPanel: tabValue.efPanel);
  }

  Future<void> _addEfProjectAsync() async {
    final filePath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select EF Project',
    );

    if (filePath == null) {
      //TODO: Pop an error dialog here.
      return;
    }

    final fileUri = Uri.tryParse(filePath);

    if (fileUri == null) {
      //TODO: Pop an error dialog here.
      return;
    }

    final output = widget.tabbedViewController.tabs.anyWithResult((x) =>
        x.value is! AddEfPanelTabDataValue &&
        (x.value as EfPanelTabDataValue).efPanel.directoryUrl == fileUri);
    if (output.passed) {
      widget.tabbedViewController.selectedIndex =
          widget.tabbedViewController.tabs.indexOf(output.output);
      return;
    }

    final efPanel = EfPanel(
      directoryUrl: fileUri,
    );
    final id = await _efPanelRepository.insertOrUpdateAsync(efPanel);

    _addProjectTab(efPanel.copyWith(id: id));
  }

  void _addProjectTab(EfPanel efPanel) {
    final efPanelTabDataValue = EfPanelTabDataValue(efPanel: efPanel);
    widget.tabbedViewController.insertTab(
      widget.tabbedViewController.tabs.length - 1,
      EfPanelTabData(
        value: efPanelTabDataValue,
        text: efPanelTabDataValue.displayText,
      ),
    );
  }

  Future<void> _loadPreviousTabsAsync() async {
    final results = await _efPanelRepository.getAllAsync();
    final efPanelInTabs = widget.tabbedViewController.tabs
        .where((x) => x.value is! AddEfPanelTabDataValue)
        .map((e) => e.value as EfPanelTabDataValue);
    results
        .where((x) => efPanelInTabs
            .every((y) => y.efPanel.directoryUrl != x.directoryUrl))
        .forEach(_addProjectTab);
  }

  Future<void> _removeFromStorageAsync({
    required EfPanel efPanel,
  }) {
    return _efPanelRepository.deleteAsync(efPanel);
  }
}
