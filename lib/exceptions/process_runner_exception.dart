import 'package:ef_steroid/services/process_runner/model/process_runner_result.dart';

class ProcessRunnerException implements Exception {
  final String message;

  final String? stackTrace;

  ProcessRunnerException({
    required this.message,
    this.stackTrace,
  });

  ProcessRunnerException.fromFailureProcessRunnerResult({
    required FailureProcessRunnerResult failureProcessRunnerResult,
  })  : message = failureProcessRunnerResult.output,
        stackTrace = failureProcessRunnerResult.stackTrace;

  @override
  String toString() {
    final sb = StringBuffer();
    sb.writeln('ProcessRunnerException: $message');
    if (stackTrace != null) {
      sb.writeln('StackTrace: $stackTrace');
    }
    return sb.toString();
  }
}
