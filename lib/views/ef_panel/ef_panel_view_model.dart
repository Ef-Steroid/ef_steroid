import 'package:darq/darq.dart';
import 'package:fast_dotnet_ef/domain/ef_operation.dart';
import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/mixins/selection_mode_mixin.dart';
import 'package:fast_dotnet_ef/repository/repository.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel_view.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';
import 'package:get_it/get_it.dart';

class EfPanelViewModel extends ViewModelBase {
  final DotnetEfService _dotnetEfService;
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();

  final Map<EfOperation, EfOperationModel> efOperations = EfOperation.values
      .map((e) => EfOperationModel(efOperation: e))
      .toMap((element) => MapEntry(element.efOperation, element));

  late EfPanel efPanel;

  EfOperation _selectedEfOperation = EfOperation.database;

  EfOperation get selectedEfOperation => _selectedEfOperation;

  set selectedEfOperation(EfOperation efOperation) {
    if (efOperation == _selectedEfOperation) return;
    _selectedEfOperation = efOperation;
    _storeSelectedEfOperationAsync();
    notifyListeners();
  }

  EfPanelViewModel(
    this._dotnetEfService,
  );

  Future<void> updateDatabaseAsync() async {
    if (isBusy) return;
    isBusy = true;
    try {
      await _dotnetEfService.updateDatabaseAsync(
        projectUri: context
            .findAncestorWidgetOfExactType<EfPanelView>()!
            .efPanel
            .directoryUrl,
      );
    } catch (ex, stackTrace) {
      //TODO: Pop a dialog.
      logService.severe(
        'Unable to update database',
        ex,
        stackTrace,
      );
    }

    isBusy = false;
  }

  @override
  Future<void> initViewModelAsync() {
    _loadSelectedOperationAsync();
    return super.initViewModelAsync();
  }

  Future<void> _loadSelectedOperationAsync() async {
    efPanel = await _efPanelRepository
        .getAsync(efPanel.id!)
        .then((value) => value ?? efPanel);

    efOperations.values
        .updateSelectedBy((x) => x.efOperation == efPanel.selectedEfOperation);
    notifyListeners();
  }

  Future<void> _storeSelectedEfOperationAsync() {
    return _efPanelRepository.insertOrUpdateAsync(efPanel.copyWith(
      selectedEfOperation: selectedEfOperation,
    ));
  }
}

class EfOperationModel with SelectionModeMixin {
  final EfOperation efOperation;

  EfOperationModel({
    required this.efOperation,
  });
}
