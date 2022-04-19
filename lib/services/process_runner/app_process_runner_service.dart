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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async_task/async_task.dart';
import 'package:ef_steroid/services/log/log_service.dart';
import 'package:ef_steroid/services/process_runner/model/process_runner_argument.dart';
import 'package:ef_steroid/services/process_runner/model/process_runner_result.dart';
import 'package:ef_steroid/services/process_runner/process_runner_service.dart';
import 'package:ef_steroid/services/process_runner/process_runner_type.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:quiver/strings.dart';

@Injectable(as: ProcessRunnerService)
class AppProcessRunnerService extends ProcessRunnerService {
  final ProcessRunnerType _processRunnerType;

  AppProcessRunnerService(
    @factoryParam this._processRunnerType,
  );

  @override
  String getCompleteCommand({
    required String executable,
    required List<String> args,
  }) {
    return '$executable ${args.join(' ')}';
  }

  @override
  Future<ProcessRunnerResult> runAsync({
    required String executable,
    required List<String> arguments,
  }) async {
    final asyncExecutor = AsyncExecutor(
      taskTypeRegister: _runExecutableAsync(executable, arguments),
    );

    if (kDebugMode) {
      asyncExecutor.logger.enabled = true;
      asyncExecutor.logger.enabledExecution = true;
    }

    final result = await asyncExecutor.execute(
      _ProcessRunner(
        executable: executable,
        arguments: arguments,
      ),
    );
    await asyncExecutor.close();

    final processRunnerResultType = ProcessRunnerResult.fromJson(result).type;
    switch (processRunnerResultType) {
      case ProcessRunnerResultType.successful:
        final successfulProcessRunnerResult =
            SuccessfulProcessRunnerResult.fromJson(result);
        _logEfResult(result: successfulProcessRunnerResult);
        return successfulProcessRunnerResult;
      case ProcessRunnerResultType.failure:
        final failureProcessRunnerResult =
            FailureProcessRunnerResult.fromJson(result);
        _logEfResult(result: failureProcessRunnerResult);
        return failureProcessRunnerResult;
    }
  }

  void _logEfResult({
    required ProcessRunnerResult result,
  }) {
    if (_processRunnerType == ProcessRunnerType.other) return;
    final logService = GetIt.I<LogService>(param1: ProcessRunnerResult);

    switch (result.type) {
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

  static AsyncTaskRegister _runExecutableAsync(
    String executable,
    List<String> arguments,
  ) {
    return () {
      return [
        _ProcessRunner(
          executable: executable,
          arguments: arguments,
        ),
      ];
    };
  }
}

class _ProcessRunner extends AsyncTask<String, Map<String, dynamic>> {
  final String executable;

  final List<String> arguments;

  _ProcessRunner({
    required this.executable,
    required this.arguments,
  });

  @override
  _ProcessRunner instantiate(
    String parameters, [
    Map<String, SharedData>? sharedData,
  ]) {
    return _ProcessRunner(
      arguments: arguments,
      executable: executable,
    );
  }

  @override
  String parameters() {
    return jsonEncode(
      ProcessRunnerArgument(
        arguments: arguments,
        executable: executable,
      ),
    );
  }

  @override
  FutureOr<Map<String, dynamic>> run() async {
    try {
      final processResult = await Process.run(
        executable,
        arguments,
        environment: Platform.isMacOS
            ? {
                'PATH':
                    '${Platform.environment['HOME']}/.dotnet/tools:/usr/local/share/dotnet',
              }
            : null,
      );
      return SuccessfulProcessRunnerResult.fromProcessResult(
        processResult: processResult,
      ).toJson();
    } on ProcessException catch (ex, stackTrace) {
      if (kDebugMode) {
        print(ex);
        print(stackTrace);
      }

      return FailureProcessRunnerResult(
        output: ex.toString(),
        stackTrace: stackTrace.toString(),
      ).toJson();
    } catch (ex, stackTrace) {
      if (kDebugMode) {
        print(ex);
        print(stackTrace);
      }

      return FailureProcessRunnerResult(
        output: ex.toString(),
        stackTrace: stackTrace.toString(),
      ).toJson();
    }
  }
}
