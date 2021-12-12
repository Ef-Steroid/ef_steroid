/// Holds the test result of a list testing operation.
class IterableTestOutput<T> {
  /// Indicate if the test passed.
  final bool passed;

  /// The element that passes the test.
  ///
  /// Take note that this can still be null if the element in the list was
  /// natively null.
  final T? output;

  /// The [index] of [output].
  final int index;

  IterableTestOutput({
    required this.passed,
    this.output,
    required this.index,
  });

  @override
  String toString() {
    return 'IterableTestOutput{passed: $passed, output: $output, index: $index}';
  }
}
