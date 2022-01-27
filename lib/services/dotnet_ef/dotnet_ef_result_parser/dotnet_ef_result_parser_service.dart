import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_result_parser/model/dotnet_ef_result_line.dart';

abstract class DotnetEfResultParserService {
  /// Parse the Dotnet Ef CLI tool result to [DotnetEfResultLine] in the exact
  /// sequence.
  List<DotnetEfResultLine> parseDotnetEfResult({
    required String stdout,
  });

  /// Extract the json data from [stdout].
  String extractJsonOutput({
    required String? stdout,
  });

  /// Extract the json data from [dotnetEfResultLines].
  String extractJsonOutputFromDotnetEfResultLines({
    required List<DotnetEfResultLine> dotnetEfResultLines,
  });
}
