import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_annotation/json_annotation.dart';

mixin SelectionModeMixin {
  @JsonKey(ignore: true)
  bool isSelected = false;
}

extension SelectionModeMixinListExt<T extends SelectionModeMixin> on List<T> {
  int get selectedIndex => indexWhere((T x) => x.isSelected == true);
}

extension SelectionModeMixinIterableExt<T extends SelectionModeMixin>
    on Iterable<T> {
  void updateSelected(T? item) => forEach((x) => x.isSelected = (x == item));

  void updateSelectedBy(bool Function(T element) test) =>
      forEach((x) => x.isSelected = test(x));

  T? get selected => firstWhereOrNull((T x) => x.isSelected == true);

  /// Check if there is any of the items is selected.
  bool get hasSelected => any((x) => x.isSelected == true);
}
