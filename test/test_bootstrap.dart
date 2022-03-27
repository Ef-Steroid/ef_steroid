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
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:ef_steroid/helpers/log_helper.dart';
import 'package:ef_steroid/services/log/log_service.dart';
import 'package:ef_steroid/services/service_locator.dart' as sl;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class TestBootstrap {
  static Future<void> runAsync() async {
    await sl.configure();
    GetIt.I<LogService>().onRecord.listen((logRecord) {
      final log = LogHelper.formatLog(logRecord: logRecord);
      print(log);
    });
  }

  static Directory getProjectRootDirectory() {
    // This implementation takes advantage of the fact that Platform.script
    // returns `<Project root>/main.dart`.
    return File.fromUri(Platform.script).parent;
  }

  /// Build the dotnet core project in [projectUri].
  static Future<void> buildDotnetProjectAsync({
    required Uri projectUri,
  }) {
    return Process.run(
      'dotnet',
      [
        'build',
        projectUri.toFilePath(),
      ],
    );
  }
}
