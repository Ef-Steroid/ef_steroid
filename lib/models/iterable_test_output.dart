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
