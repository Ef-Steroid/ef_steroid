import 'package:fast_dotnet_ef/helpers/context_helper.dart';
import 'package:flutter/material.dart';

class ViewModelBase extends ChangeNotifier {
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
}
