import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class EfPanelView extends StatefulWidget {
  final Uri fileUri;

  const EfPanelView({
    Key? key,
    required this.fileUri,
  }) : super(key: key);

  @override
  State<EfPanelView> createState() => _EfPanelViewState();
}

class _EfPanelViewState extends State<EfPanelView> {
  final DotnetEfService _dotnetEfService = GetIt.I<DotnetEfService>();
  final LogService _logService = GetIt.I<LogService>();

  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return Column(
      children: [
        if (_isBusy)
          const CircularProgressIndicator()
        else
          OutlinedButton(
            onPressed: _updateDatabaseAsync,
            child: Text(l('UpdateDatabase')),
          ),
        OutlinedButton(
          onPressed: _collectLogAsync,
          child: Text(l('CollectLog')),
        ),
      ],
    );
  }

  Future<void> _updateDatabaseAsync() async {
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});
    await _dotnetEfService.updateDatabaseAsync(projectUri: widget.fileUri);

    _isBusy = false;
    setState(() {});
  }

  Future<void> _collectLogAsync() async {
    final log = _logService.getLog();
    if (kDebugMode) {
      for (final e in log) {
        print('[${e.level}] ${e.loggerName}: ${e.message}\n ${e.error}');
      }
    }
  }
}
