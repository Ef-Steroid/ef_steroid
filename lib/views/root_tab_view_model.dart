import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/helpers/list_helpers.dart';
import 'package:fast_dotnet_ef/helpers/tabbed_view_controller_helper.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
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
  Future<void> initViewModelAsync({
    required InitParam initParam,
  }) async {
    _logService.info('Init RootTabViewModel');
    await _loadLastSessionTabsAsync();
    return super.initViewModelAsync(initParam: initParam);
  }

  Future<void> _loadLastSessionTabsAsync() async {
    _logService.info('Start loading last session tabs');

    _logService.info('Start getting last session tabs from db');
    final results = await _efPanelRepository.getAllAsync();
    _logService.info('Done getting last session tabs from db');

    final efPanelInTabs = tabbedViewController.tabs
        .where((x) => x.value is! AddEfPanelTabDataValue)
        .map((e) => e.value as EfPanelTabDataValue);
    results
        .where(
          (x) => efPanelInTabs
              .every((y) => y.efPanel.directoryUri != x.directoryUri),
        )
        .forEach(_addProjectTab);
    _logService.info('Done loading last session tabs');
  }

  Future<void> addEfProjectAsync() async {
    final l = AL.of(context).text;
    final filePath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: l('SelectEfProject'),
      lockParentWindow: true,
    );

    if (filePath == null) {
      _logService.info('User cancels the picker.');
      return;
    }

    final fileUri = Uri.tryParse(filePath);

    if (fileUri == null) {
      final message = 'Unable to parse file path: $filePath to Uri.';
      _logService.severe(message);
      await dialogService.showDefaultDialog(
        context,
        title: l('SomethingWentWrong'),
        msg: message,
      );
      return;
    }

    final output = tabbedViewController.tabs.anyWithResult(
      (x) =>
          x.value is! AddEfPanelTabDataValue &&
          (x.value as EfPanelTabDataValue).efPanel.directoryUri == fileUri,
    );
    if (output.passed) {
      tabbedViewController.selectedIndex =
          tabbedViewController.tabs.indexOf(output.output);
      return;
    }

    final efPanel = EfPanel(
      directoryUri: fileUri,
    );
    final id = await _efPanelRepository.insertOrUpdateAsync(efPanel);

    final addedEfPanelTabDataValue = _addProjectTab(efPanel.copyWith(id: id));
    _logService.info('Done adding ef project');

    _logService.info('Start reset tab closable');
    tabbedViewController.updateClosable(
      selectedTabDataValue: addedEfPanelTabDataValue,
    );
    _logService.info('Done reset tab closable');
  }

  /// Add project tab.
  ///
  /// Return the added [EfPanelTabDataValue].
  EfPanelTabDataValue _addProjectTab(EfPanel efPanel) {
    final efPanelTabDataValue = EfPanelTabDataValue(efPanel: efPanel);
    tabbedViewController.insertTab(
      tabbedViewController.tabs.length - 1,
      EfPanelTabData(
        value: efPanelTabDataValue,
        text: efPanelTabDataValue.displayText,
        keepAlive: efPanelTabDataValue.keepAlive,
        closable: true,
      ),
    );
    _logService.info('Done adding ef project tab');
    return efPanelTabDataValue;
  }

  Future<void> removeFromStorageAsync({
    required EfPanel efPanel,
  }) {
    return _efPanelRepository.deleteAsync(efPanel);
  }

  @override
  void reassemble() {
    _loadLastSessionTabsAsync();
  }
}
