import 'package:ef_steroid/helpers/context_helper.dart';
import 'package:ef_steroid/services/dialog/dialog_service.dart';
import 'package:ef_steroid/services/log/log_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class InitParam {
  final dynamic param;

  const InitParam({
    this.param,
  });
}

class ViewModelBase extends ChangeNotifier {
  @protected
  final LogService logService = GetIt.I<LogService>();
  @protected
  final DialogService dialogService = GetIt.I<DialogService>();
  bool _hasDispose = false;

  bool get hasDispose => _hasDispose;

  BuildContext? _context;

  BuildContext get context => _context ?? ContextHelper.fallbackContext!;

  set context(BuildContext context) => _context = context;

  bool _isBusy = false;

  bool get isBusy => _isBusy;

  set isBusy(bool isBusy) {
    if (_isBusy == isBusy) return;
    _isBusy = isBusy;
    notifyListeners();
  }

  @override
  @protected
  void notifyListeners({bool? isBusy}) {
    if (isBusy != null) _isBusy = isBusy;
    if (!hasDispose) super.notifyListeners();
  }

  Future<void> initViewModelAsync({
    required InitParam initParam,
  }) {
    return Future.value();
  }

  @override
  void dispose() {
    super.dispose();
    _hasDispose = true;
  }
}
