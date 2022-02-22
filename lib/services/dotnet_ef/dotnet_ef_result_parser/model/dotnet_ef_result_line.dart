import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_result_parser/data/dotnet_ef_result_type.dart';

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

extension DotnetEfResultLineListExt on List<DotnetEfResultLine> {
  bool get hasError => any(_testError);

  Iterable<DotnetEfResultLine> get errorLines => where(_testError);

  bool _testError(DotnetEfResultLine line) =>
      line.dotnetEfResultType == DotnetEfResultType.error;
}
