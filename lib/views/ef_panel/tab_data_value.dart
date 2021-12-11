import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:path/path.dart' as path;

abstract class TabDataValue {
  /// The display text for the current tab.
  final String displayText;

  /// Indicate if the tab is closable.
  final bool closable;

  /// Indicate if the TabView should keep the tab alive.
  final bool keepAlive;

  TabDataValue({
    required this.displayText,
    required this.closable,
    required this.keepAlive,
  });
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
          closable: true,
          keepAlive: true,
        );

  static String _generateTabDisplayTextFromUri(EfPanel efPanel) {
    final name = path.basenameWithoutExtension(
        Uri.decodeFull(efPanel.directoryUrl.toString()));
    return name;
  }
}

class AddEfPanelTabDataValue extends TabDataValue {
  AddEfPanelTabDataValue({
    required String displayText,
  }) : super(
          displayText: displayText,
          closable: false,
          keepAlive: false,
        );
}
