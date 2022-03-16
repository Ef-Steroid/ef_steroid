/*
 * Copyright 2022-2022 MOK KAH WAI and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:ef_steroid/helpers/context_helper.dart';
import 'package:ef_steroid/helpers/intl/language_helper.dart';
import 'package:ef_steroid/helpers/tabbed_view_controller_helper.dart';
import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/services/navigation/navigation_service.dart';
import 'package:ef_steroid/views/ef_panel/ef_panel_tab_data.dart';
import 'package:ef_steroid/views/ef_panel/tab_data_value.dart';
import 'package:ef_steroid/views/home/home_view_model.dart';
import 'package:ef_steroid/views/root/root_view.dart';
import 'package:ef_steroid/views/root_tab_view.dart';
import 'package:ef_steroid/views/view_model_base.dart';
import 'package:ef_steroid/views/widgets/mvvm_binding_widget.dart';
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
    vm.initViewModelAsync(
      initParam: const InitParam(),
    );
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
                title: 'Ef Steroid',
                locale: LanguageHelper.languages[snapshotData.locale]?.locale ??
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
      },
    );
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
