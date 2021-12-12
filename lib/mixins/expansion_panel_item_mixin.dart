import 'package:flutter/material.dart';

mixin ExpansionPanelItemMixin {
  /// This is used in [Scrollable.ensureVisible].
  final GlobalKey expansionItemKey = GlobalKey();

  bool isExpanded = false;
}
