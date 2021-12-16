import 'package:tabbed_view/tabbed_view.dart';

extension TabbedViewControllerHelper on TabbedViewController {
  TabData? get selectedTab {
    final selectedIndex = this.selectedIndex;
    return selectedIndex == null ? null : tabs[selectedIndex];
  }
}
