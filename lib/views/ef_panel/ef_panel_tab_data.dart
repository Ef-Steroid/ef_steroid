import 'package:fast_dotnet_ef/views/ef_panel/tab_data_value.dart';
import 'package:flutter/material.dart';
import 'package:tabbed_view/tabbed_view.dart';

/// EfPanelTabData.
///
/// This class is created just for securing the [value] type.
class EfPanelTabData<T extends TabDataValue> extends TabData {
  EfPanelTabData({
    bool keepAlive = false,
    required T value,
    required String text,
    List<TabButton> buttons = const [],
    Widget? content,
    bool closable = true,
  }) : super(
          value: value,
          text: text,
          buttons: buttons,
          closable: closable,
          content: content,
          keepAlive: keepAlive,
        );
}
