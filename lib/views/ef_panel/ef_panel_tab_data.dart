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
