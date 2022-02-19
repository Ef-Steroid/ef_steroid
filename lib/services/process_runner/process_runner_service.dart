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
