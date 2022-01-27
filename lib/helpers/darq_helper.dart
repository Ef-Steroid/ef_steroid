import 'package:darq/darq.dart';

class DarqHelper {
  static EqualityComparer<bool> get _boolEqualityComparer =>
      EqualityComparer<bool>(
        comparer: (bool left, bool right) => left == right,
        hasher: (value) => value.hashCode,
        sorter: (bool left, bool right) =>
            (left ? 1 : 0).compareTo(right ? 1 : 0),
      );

  static void registerEqualityComparer() {
    EqualityComparer.registerEqualityComparer(_boolEqualityComparer);
  }
}
