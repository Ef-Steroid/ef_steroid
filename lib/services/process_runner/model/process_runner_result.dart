import 'dart:io';

import 'package:ef_steroid/services/log/log_service.dart';
import 'package:get_it/get_it.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/strings.dart';

part 'process_runner_result.g.dart';

enum ProcessRunnerResultType {
  successful,
  failure,
}

/// The base type for process runner results.
///
/// Check the following subclasses:
/// - [SuccessfulProcessRunnerResult]
/// - [FailureProcessRunnerResult]
@JsonSerializable()
class ProcessRunnerResult {
  final ProcessRunnerResultType type;

  ProcessRunnerResult({
    required this.type,
  });

  factory ProcessRunnerResult.fromJson(Map<String, dynamic> json) =>
      _$ProcessRunnerResultFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessRunnerResultToJson(this);

  void logResult() {
    final logService = GetIt.I<LogService>();

    switch (type) {
      case ProcessRunnerResultType.successful:
        final successfulProcessRunnerResult =
            this as SuccessfulProcessRunnerResult;
        if (successfulProcessRunnerResult.stdout != null) {
          logService.finest(successfulProcessRunnerResult.stdout);
        }
        if (isNotBlank(successfulProcessRunnerResult.stderr)) {
          logService.warning(successfulProcessRunnerResult.stderr);
        }
        break;
      case ProcessRunnerResultType.failure:
        final failureProcessRunnerResult = this as FailureProcessRunnerResult;
        logService.severe(failureProcessRunnerResult.output);
        break;
    }
  }
}

@JsonSerializable()
class SuccessfulProcessRunnerResult extends ProcessRunnerResult {
  /// Exit code for the process.
  ///
  /// See [Process. `exitCode] for more information in the exit code
  /// value.
  final int exitCode;

  /// Standard output from the process. The value used for the
  /// `stdoutEncoding` argument to `Process.run` determines the type. If
  /// `null` was used, this value is of type `List<int>` otherwise it is
  /// of type `String`.
  @_BufferConverter()
  final String? stdout;

  /// Standard error from the process. The value used for the
  /// `stderrEncoding` argument to `Process.run` determines the type. If
  /// `null` was used, this value is of type `List<int>`
  /// otherwise it is of type `String`.
  @_BufferConverter()
  final String? stderr;

  /// Process id of the process.
  final int pid;

  SuccessfulProcessRunnerResult({
    required this.exitCode,
    this.stdout,
    this.stderr,
    required this.pid,
    // Placeholder for JsonSerializable to pick up and build.
    ProcessRunnerResultType type = ProcessRunnerResultType.successful,
  }) : super(type: type);

  SuccessfulProcessRunnerResult.fromProcessResult({
    required ProcessResult processResult,
  }) : this(
          exitCode: processResult.exitCode,
          stdout: processResult.stdout,
          stderr: processResult.stderr,
          pid: processResult.pid,
        );

  factory SuccessfulProcessRunnerResult.fromJson(Map<String, dynamic> json) =>
      _$SuccessfulProcessRunnerResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SuccessfulProcessRunnerResultToJson(this);
}

@JsonSerializable()
class FailureProcessRunnerResult extends ProcessRunnerResult {
  final String output;

  final String stackTrace;

  FailureProcessRunnerResult({
    required this.output,
    required this.stackTrace,
    // Placeholder for JsonSerializable to pick up and build.
    ProcessRunnerResultType type = ProcessRunnerResultType.failure,
  }) : super(
          type: type,
        );

  factory FailureProcessRunnerResult.fromJson(Map<String, dynamic> json) =>
      _$FailureProcessRunnerResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FailureProcessRunnerResultToJson(this);
}

class _BufferConverter implements JsonConverter<dynamic, String?> {
  const _BufferConverter();

  @override
  dynamic fromJson(String? json) => json;

  @override
  String? toJson(dynamic object) {
    if (object is List) {
      return systemEncoding.decode(object.cast<int>());
    }

    return object;
  }
}
