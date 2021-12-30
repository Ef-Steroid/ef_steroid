import 'dart:io';
import 'dart:isolate';

import 'package:async_task/async_task_extension.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:fast_dotnet_ef/app_settings.dart';
import 'package:fast_dotnet_ef/helpers/context_helper.dart';
import 'package:fast_dotnet_ef/helpers/intl/language_helper.dart';
import 'package:fast_dotnet_ef/helpers/tabbed_view_controller_helper.dart';
import 'package:fast_dotnet_ef/helpers/theme_helper.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/main.reflectable.dart';
import 'package:fast_dotnet_ef/services/file/resource_group_key.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:fast_dotnet_ef/services/service_locator.dart' as sl;
import 'package:fast_dotnet_ef/services/sqlite/sqlite_service.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel_tab_data.dart';
import 'package:fast_dotnet_ef/views/ef_panel/tab_data_value.dart';
import 'package:fast_dotnet_ef/views/root_tab_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tabbed_view/tabbed_view.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  WidgetsFlutterBinding.ensureInitialized();
  initializeReflectable();
  await sl.configure();
  await _handlerLogAsync();
  final setupSqliteService = _setupSqliteService();
  final setupAppSettings = AppSettings.instance.setup();
  final setupWindowMetrics = _setupWindowMetrics();
  await Future.wait([
    setupSqliteService,
    setupAppSettings,
    setupWindowMetrics,
  ]);

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;

    GetIt.I<LogService>().severe(
      'Error in isolate',
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);

  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (ex, stackTrace) async {
      GetIt.I<LogService>().severe(
        'Error in zone',
        ex,
        stackTrace,
      );
    },
  );
}

Future<void> _setupWindowMetrics() {
  return DesktopWindow.setMinWindowSize(const Size(400, 400));
}

Future<void> _handlerLogAsync() async {
  final applicationSupportDirectory =
      await path_provider.getApplicationSupportDirectory();
  final file = File(p.canonicalize(p.joinAll([
    applicationSupportDirectory.path,
    ResourceGroupKey.logs,
    // Windows path does not accept ':'.
    '${DateTime.now().toString().replaceAll(':', '')}_logs.txt',
  ])));
  await file.create(recursive: true);
  final ioSink = file.openWrite(mode: FileMode.append);
  GetIt.I<LogService>().onRecord.listen((event) {
    final log =
        '[${event.level}] ${event.loggerName}: ${event.message}\n ${event.error}';
    if (kDebugMode) {
      print(log);
    }
    ioSink.write(log);
  });
}

Future<void> _setupSqliteService() async {
  GetIt.I<LogService>().info('Start setting up SqliteService');
  await GetIt.I<SqliteService>().setupAsync();
  GetIt.I<LogService>().info('Done setting up SqliteService');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fast Dotnet Ef',
      locale: LanguageHelper.getSystemLocale(),
      localizationsDelegates: [
        AL.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageHelper.getSupportedLocales(),
      home: const MyHomePage(),
      builder: (context, child) {
        ContextHelper.fallbackContext = context;
        return BotToastInit()(
          context,
          child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeHelper.instance.themes[ThemeKey.light],
      darkTheme: ThemeHelper.instance.themes[ThemeKey.dark],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TabbedViewController tabbedViewController = TabbedViewController([]);

  int? _previousTabIndex;

  @override
  void initState() {
    super.initState();
    _setupTabs();
    _setupTabListener();
  }

  void _setupTabs() {
    final addEfPanelTabDataValue = AddEfPanelTabDataValue(displayText: '+');
    tabbedViewController.addTabs([
      EfPanelTabData(
        value: addEfPanelTabDataValue,
        text: addEfPanelTabDataValue.displayText,
        keepAlive: addEfPanelTabDataValue.keepAlive,
        closable: false,
      ),
    ]);
  }

  void _setupTabListener() {
    tabbedViewController.addListener(() {
      final selectedTabIndex = tabbedViewController.selectedIndex;
      if (selectedTabIndex == null || selectedTabIndex == _previousTabIndex) {
        return;
      }

      _previousTabIndex = selectedTabIndex;
      tabbedViewController.updateClosableBySelectedIndex(
        selectedIndex: selectedTabIndex,
      );
    });
  }

  @override
  void dispose() {
    tabbedViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RootTabView(
        tabbedViewController: tabbedViewController,
      ),
    );
  }
}
