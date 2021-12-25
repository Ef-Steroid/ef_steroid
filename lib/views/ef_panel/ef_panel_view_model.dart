import 'package:darq/darq.dart';
import 'package:fast_dotnet_ef/domain/ef_operation.dart';
import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/mixins/selection_mode_mixin.dart';
import 'package:fast_dotnet_ef/repository/repository.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:fast_dotnet_ef/views/view_model_base.dart';
import 'package:get_it/get_it.dart';

class EfPanelViewModel extends ViewModelBase {
  final LogService _logService;
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
    this._logService,
  );

  @override
  Future<void> initViewModelAsync() async {
    _logService.info('Start init EfPanelViewModel');
    await _loadSelectedOperationAsync();
    _logService.info('Done init EfPanelViewModel');
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
