import 'package:bot_toast/bot_toast.dart';
import 'package:fast_dotnet_ef/helpers/context_helper.dart';
import 'package:fast_dotnet_ef/helpers/intl/language_helper.dart';
import 'package:fast_dotnet_ef/helpers/tabbed_view_controller_helper.dart';
import 'package:fast_dotnet_ef/helpers/theme_helper.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/services/navigation/navigation_service.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel_tab_data.dart';
import 'package:fast_dotnet_ef/views/ef_panel/tab_data_value.dart';
import 'package:fast_dotnet_ef/views/home/home_view_model.dart';
import 'package:fast_dotnet_ef/views/root/root_view.dart';
import 'package:fast_dotnet_ef/views/root_tab_view.dart';
import 'package:fast_dotnet_ef/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:tabbed_view/tabbed_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeViewModel vm = GetIt.I<HomeViewModel>();

  @override
  void initState() {
    super.initState();
    vm.initViewModelAsync();
  }

  @override
  Widget build(BuildContext context) {
    return MVVMBindingWidget<HomeViewModel>(
        viewModel: vm,
        builder: (context, vm, child) {
          return HomeViewModelProvider(
            homeViewModel: vm,
            child: StreamBuilder<Preference>(
              stream: vm.preferenceStream,
              initialData: vm.currentPreference,
              builder: (context, snapshot) {
                final snapshotData = snapshot.data!;
                return MaterialApp(
                  title: 'Fast Dotnet Ef',
                  locale:
                      LanguageHelper.languages[snapshotData.locale]?.locale ??
                          LanguageHelper.getSystemLocale(),
                  localizationsDelegates: [
                    AL.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: LanguageHelper.getSupportedLocales(),
                  home: const HomePage(),
                  navigatorKey: GetIt.I<NavigationService>().navigatorKey,
                  navigatorObservers: <NavigatorObserver>[
                    BotToastNavigatorObserver(),
                  ],
                  builder: (context, child) {
                    ContextHelper.fallbackContext = context;
                    return BotToastInit()(
                      context,
                      child ?? const SizedBox.shrink(),
                    );
                  },
                  theme: ThemeHelper.instance.themes[ThemeKey.light],
                  darkTheme: ThemeHelper.instance.themes[ThemeKey.dark],
                  themeMode: snapshotData.theme.toThemeMode(),
                );
              },
            ),
          );
        });
  }
}

class HomeViewModelProvider extends InheritedWidget {
  final HomeViewModel homeViewModel;

  const HomeViewModelProvider({
    required this.homeViewModel,
    Key? key,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(HomeViewModelProvider oldWidget) =>
      homeViewModel != oldWidget.homeViewModel;

  static HomeViewModelProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeViewModelProvider>();
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return RootView(
      child: Scaffold(
        body: RootTabView(
          tabbedViewController: tabbedViewController,
        ),
      ),
    );
  }
}
