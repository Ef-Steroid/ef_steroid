import 'package:fast_dotnet_ef/helpers/list_helpers.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_result_parser/data/dotnet_ef_result_type.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_result_parser/dotnet_ef_result_parser_service.dart';
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_result_parser/model/dotnet_ef_result_line.dart';
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
