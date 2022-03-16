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

import 'package:ef_steroid/views/ef_panel/tab_data_value.dart';
import 'package:tabbed_view/tabbed_view.dart';

extension TabbedViewControllerHelper on TabbedViewController {
  TabData? get selectedTab {
    final selectedIndex = this.selectedIndex;
    return selectedIndex == null ? null : tabs[selectedIndex];
  }

  /// {@macro tabbed_view_controller_helper.TabbedViewControllerHelper.updateClosable}
  ///
  /// - [selectedIndex] -> The selected tab index. See [TabbedViewController.selectedIndex].
  void updateClosableBySelectedIndex({
    required int selectedIndex,
  }) {
    final selectedTab = this.selectedTab;
    if (selectedTab == null) {
      throw StateError('Unable to find selected tab.');
    }

    final selectedTabValue = selectedTab.value;

    _updateClosableCoreAsync(
      selectedTabDataValue: selectedTabValue as TabDataValue,
    );
  }

  /// {@template tabbed_view_controller_helper.TabbedViewControllerHelper.updateClosable}
  ///
  /// Update [TabData.closable].
  ///
  /// {@endtemplate}
  void updateClosable({
    required TabDataValue selectedTabDataValue,
  }) =>
      _updateClosableCoreAsync(
        selectedTabDataValue: selectedTabDataValue,
      );

  void _updateClosableCoreAsync({
    required TabDataValue selectedTabDataValue,
  }) {
    for (final tab in tabs) {
      final tabValue = tab.value;

      if (tabValue is! EfPanelTabDataValue) continue;

      tab.closable = tabValue.id == selectedTabDataValue.id;
    }
  }
}
