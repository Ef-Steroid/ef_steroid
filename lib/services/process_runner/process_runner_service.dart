import 'package:fast_dotnet_ef/services/process_runner/model/process_runner_result.dart';

abstract class ProcessRunnerService {
  Future<ProcessRunnerResult> runAsync(
    String executable,
    List<String> arguments,
  );
}
