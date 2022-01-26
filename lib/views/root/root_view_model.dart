import 'package:ef_steroid/services/app/platform_channels/menu_bar/menu_bar_service.dart';
import 'package:ef_steroid/views/view_model_base.dart';

class RootViewModel extends ViewModelBase {
  final MenuBarService _menuBarService;

  RootViewModel(
    this._menuBarService,
  );

  @override
  Future<void> initViewModelAsync({
    required InitParam initParam,
  }) {
    _menuBarService.setup();
    return super.initViewModelAsync(initParam: initParam);
  }
}
