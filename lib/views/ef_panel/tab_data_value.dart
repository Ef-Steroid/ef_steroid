import 'package:equatable/equatable.dart';
import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/helpers/uri_helper.dart';
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
        Uri.decodeFull(efPanel.directoryUrl.toDecodedString()));
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
