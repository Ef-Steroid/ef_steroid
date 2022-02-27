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

import 'package:ef_steroid/helpers/list_helpers.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_result_parser/data/dotnet_ef_result_type.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_result_parser/dotnet_ef_result_parser_service.dart';
import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_result_parser/model/dotnet_ef_result_line.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: DotnetEfResultParserService)
class AppDotnetEfResultParserService extends DotnetEfResultParserService {
  @override
  List<DotnetEfResultLine> parseDotnetEfResult({
    required String stdout,
  }) {
    final dotnetEfResultLines = <DotnetEfResultLine>[];

    stdout.split('\n').forEach((line) {
      final testResult = DotnetEfResultType.values
          .anyWithResult((x) => x.dotnetEfResultRegex.hasMatch(line));
      if (testResult.passed) {
        dotnetEfResultLines.add(
          DotnetEfResultLine(
            dotnetEfResultType: testResult.output!,
            line: line
                .replaceFirst(testResult.output!.dotnetEfResultRegex, '')
                .trim(),
          ),
        );
        return;
      }

      // We don't discard the line if the test result fails since it could be due
      // to Microsoft writing newline in message, though I didn't meet this
      // before.
      final lastDotnetEfResultLine = dotnetEfResultLines.last;
      dotnetEfResultLines.last = lastDotnetEfResultLine.copyWith(
        line: '${lastDotnetEfResultLine.line}\n$line',
      );
    });

    return dotnetEfResultLines;
  }

  @override
  String extractJsonOutput({
    required String? stdout,
  }) {
    if (stdout == null) return '';

    final dotnetEfResultLines = parseDotnetEfResult(stdout: stdout);

    return extractJsonOutputFromDotnetEfResultLines(
      dotnetEfResultLines: dotnetEfResultLines,
    );
  }

  @override
  String extractJsonOutputFromDotnetEfResultLines({
    required List<DotnetEfResultLine> dotnetEfResultLines,
  }) {
    return dotnetEfResultLines
        .where((x) => x.dotnetEfResultType == DotnetEfResultType.data)
        .map((e) => e.line)
        .join('')
        .replaceAll(RegExp(r'\s'), '');
  }
}
