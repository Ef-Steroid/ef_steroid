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

import 'package:ef_steroid/services/process_runner/model/process_runner_result.dart';

abstract class ProcessRunnerService {
  /// Combine the [executable] and [args] as a string that is ordinary run in terminal.
  String getCompleteCommand({
    required String executable,
    required List<String> args,
  });

  Future<ProcessRunnerResult> runAsync({
    required String executable,
    required List<String> arguments,
  });
}
