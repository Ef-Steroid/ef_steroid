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

import 'package:equatable/equatable.dart';
import 'package:ef_steroid/domain/ef_panel.dart';

import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

abstract class TabDataValue with EquatableMixin {
  final UuidValue id;

  /// The display text for the current tab.
  final String displayText;

  /// Indicate if the TabView should keep the tab alive.
  final bool keepAlive;

  /// Equality comparer.
  ///
  /// We take [id] into consideration only.
  @override
  List<Object?> get props => [
        id,
      ];

  TabDataValue({
    required this.displayText,
    required this.keepAlive,
    UuidValue? id,
  }) : id = id ?? const Uuid().v1obj();
}

class EfPanelTabDataValue extends TabDataValue {
  /// The uri for the current tab.
  ///
  /// Typically a file uri that targets the EF project.
  final EfPanel efPanel;

  EfPanelTabDataValue({
    required this.efPanel,
  }) : super(
          displayText: _generateTabDisplayTextFromUri(efPanel),
          keepAlive: true,
        );

  static String _generateTabDisplayTextFromUri(EfPanel efPanel) {
    final name = path.basenameWithoutExtension(
      Uri.decodeFull(efPanel.directoryUri.toFilePath()),
    );
    return name;
  }
}

class AddEfPanelTabDataValue extends TabDataValue {
  AddEfPanelTabDataValue({
    required String displayText,
  }) : super(
          displayText: displayText,
          keepAlive: false,
        );
}
