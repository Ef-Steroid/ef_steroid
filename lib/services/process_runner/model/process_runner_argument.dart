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

import 'package:json_annotation/json_annotation.dart';

part 'process_runner_argument.g.dart';

@JsonSerializable()
class ProcessRunnerArgument {
  final String executable;

  final List<String> arguments;

  ProcessRunnerArgument({
    required this.executable,
    required this.arguments,
  });

  factory ProcessRunnerArgument.fromJson(Map<String, dynamic> json) =>
      _$ProcessRunnerArgumentFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessRunnerArgumentToJson(this);
}
