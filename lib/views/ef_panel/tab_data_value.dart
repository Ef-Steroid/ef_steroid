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
  final Uri uri;

  EfPanelTabDataValue({
    required this.uri,
  }) : super(
          displayText: uri.toString(),
          closable: true,
          keepAlive: true,
        );
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
