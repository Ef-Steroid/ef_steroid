import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/helpers/list_helpers.dart';
import 'package:fast_dotnet_ef/repository/repository.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel_tab_data.dart';
import 'package:fast_dotnet_ef/views/ef_panel/tab_data_value.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tabbed_view/tabbed_view.dart';

class RootTabViewModel extends ViewModelBase with ReassembleHandler {
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();
  final LogService _logService;

  late TabbedViewController tabbedViewController;

  RootTabViewModel(
    this._logService,
  );

  @override
  Future<void> initViewModelAsync() async {
    await _loadPreviousTabsAsync();
    return super.initViewModelAsync();
  }

  Future<void> _loadPreviousTabsAsync() async {
    final results = await _efPanelRepository.getAllAsync();
    final efPanelInTabs = tabbedViewController.tabs
        .where((x) => x.value is! AddEfPanelTabDataValue)
        .map((e) => e.value as EfPanelTabDataValue);
    results
        .where((x) => efPanelInTabs
            .every((y) => y.efPanel.directoryUrl != x.directoryUrl))
        .forEach(_addProjectTab);
  }

  Future<void> addEfProjectAsync() async {
    final filePath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select EF Project',
    );

    if (filePath == null) {
      _logService.info('User cancels the picker.');
      return;
    }

    final fileUri = Uri.tryParse(filePath);

    if (fileUri == null) {
      //TODO: Pop an error dialog here.
      _logService.severe('Unable to parse file path: $filePath to Uri.');
      return;
    }

    final output = tabbedViewController.tabs.anyWithResult((x) =>
        x.value is! AddEfPanelTabDataValue &&
        (x.value as EfPanelTabDataValue).efPanel.directoryUrl == fileUri);
    if (output.passed) {
      tabbedViewController.selectedIndex =
          tabbedViewController.tabs.indexOf(output.output);
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
    tabbedViewController.insertTab(
      tabbedViewController.tabs.length - 1,
      EfPanelTabData(
        value: efPanelTabDataValue,
        text: efPanelTabDataValue.displayText,
        keepAlive: efPanelTabDataValue.keepAlive,
        closable: efPanelTabDataValue.closable,
      ),
    );
  }

  Future<void> removeFromStorageAsync({
    required EfPanel efPanel,
  }) {
    return _efPanelRepository.deleteAsync(efPanel);
  }

  @override
  void reassemble() {
    _loadPreviousTabsAsync();
  }
}
