import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_result_parser/data/dotnet_ef_result_type.dart';

class DotnetEfResultLine {
  final DotnetEfResultType dotnetEfResultType;

  final String line;

  DotnetEfResultLine({
    required this.dotnetEfResultType,
    required this.line,
  });

  DotnetEfResultLine copyWith({
    DotnetEfResultType? dotnetEfResultType,
    String? line,
  }) {
    return DotnetEfResultLine(
      dotnetEfResultType: dotnetEfResultType ?? this.dotnetEfResultType,
      line: line ?? this.line,
    );
  }
}
