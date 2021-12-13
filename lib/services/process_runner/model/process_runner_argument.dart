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
