import 'package:ef_steroid/models/iterable_test_output.dart';

typedef Test<T> = bool Function(T element);

extension IterableExt<T> on Iterable<T> {
  Iterable<T> whereIf(
    bool condition,
    Test<T> test, {
    bool Function(T element)? orElse,
  }) =>
      condition
          ? where(test)
          : orElse != null
              ? where(orElse)
              : this;

  IterableTestOutput<T> anyWithResult(Test<T> test) {
    var passed = false;
    T? result;
    var index = 0;
    for (final element in this) {
      if (test(element)) {
        passed = true;
        result = element;
        break;
      }
      index++;
    }
    if (!passed) {
      index = -1;
    }
    return IterableTestOutput(
      passed: passed,
      output: result,
      index: index,
    );
  }
}
