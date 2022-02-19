import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/helpers/list_helpers.dart';
import 'package:ef_steroid/helpers/tabbed_view_controller_helper.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/repository/repository.dart';
import 'package:ef_steroid/views/ef_panel/ef_panel_tab_data.dart';
import 'package:ef_steroid/views/ef_panel/tab_data_value.dart';
import 'package:ef_steroid/views/view_model_base.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tabbed_view/tabbed_view.dart';

class RootTabViewModel extends ViewModelBase with ReassembleHandler {
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();

  late TabbedViewController tabbedViewController;

  RootTabViewModel();

  @override
  Future<void> initViewModelAsync({
    required InitParam initParam,
  }) async {
    logService.info('Init RootTabViewModel');
    await _loadLastSessionTabsAsync();
    return super.initViewModelAsync(initParam: initParam);
  }

  Future<void> _loadLastSessionTabsAsync() async {
    logService.info('Start loading last session tabs');

    logService.info('Start getting last session tabs from db');
    final results = await _efPanelRepository.getAllAsync();
    logService.info('Done getting last session tabs from db');

    final efPanelInTabs = tabbedViewController.tabs
        .where((x) => x.value is! AddEfPanelTabDataValue)
        .map((e) => e.value as EfPanelTabDataValue);
    results
        .where(
          (x) => efPanelInTabs
              .every((y) => y.efPanel.directoryUri != x.directoryUri),
        )
        .forEach(_addProjectTab);
    logService.info('Done loading last session tabs');
  }

  Future<void> addEfProjectAsync() async {
    final l = AL.of(context).text;
    final filePath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: l('SelectEfProject'),
      lockParentWindow: true,
    );

    if (filePath == null) {
      logService.info('User cancels the picker.');
      return;
    }

    final fileUri = _tryParseFileUri(filePath: filePath);

    if (fileUri == null) {
      final message = 'Unable to parse file path: $filePath to Uri.';
      logService.severe(message);
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
    logService.info('Done adding ef project');

    logService.info('Start reset tab closable');
    tabbedViewController.updateClosable(
      selectedTabDataValue: addedEfPanelTabDataValue,
    );
    logService.info('Done reset tab closable');
  }

  Uri? _tryParseFileUri({
    required String filePath,
  }) {
    try {
      return Uri.file(filePath);
    } catch (ex, stackTrace) {
      final message = 'Unable to parse file path: $filePath to Uri.';
      logService.severe(message, ex, stackTrace);
      return null;
    }
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
    logService.info('Done adding ef project tab');
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
