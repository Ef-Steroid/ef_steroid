import 'package:fast_dotnet_ef/helpers/context_helper.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ViewModelBase extends ChangeNotifier {
  @protected
  final LogService logService = GetIt.I<LogService>();

  BuildContext? _context;

  BuildContext get context => _context ?? ContextHelper.fallbackContext!;

  set context(BuildContext context) => _context = context;

  bool _isBusy = false;

  bool get isBusy => _isBusy;

  set isBusy(bool isBusy) {
    if(_isBusy == isBusy) return;
    _isBusy = isBusy;
    notifyListeners();
  }

  Future<void> initViewModelAsync(){
    return Future.value();
  }
}
