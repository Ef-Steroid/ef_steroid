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
