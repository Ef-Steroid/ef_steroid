import 'package:fast_dotnet_ef/services/service_locator.dart' as sl;
import 'package:fast_dotnet_ef/services/sqlite/sqlite_service.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel_tab_data.dart';
import 'package:fast_dotnet_ef/views/ef_panel/tab_data_value.dart';
import 'package:fast_dotnet_ef/views/root_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:tabbed_view/tabbed_view.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  WidgetsFlutterBinding.ensureInitialized();
  await sl.configure();
  await _setupSqliteService();
  runApp(const MyApp());
}

Future<void> _setupSqliteService() async {
  await GetIt.I<SqliteService>().setupAsync();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fast Dotnet Ef',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(),
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

  @override
  void initState() {
    super.initState();
    tabbedViewController.addTabs([
      AddEfPanelTabDataValue(displayText: '+'),
    ].map((e) => EfPanelTabData(
          value: e,
          text: e.displayText,
          closable: e.closable,
          keepAlive: e.keepAlive,
        )));
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
