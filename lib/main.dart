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

import 'dart:io';
import 'dart:isolate';

import 'package:async_task/async_task_extension.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:ef_steroid/app_settings.dart';
import 'package:ef_steroid/helpers/darq_helper.dart';
import 'package:ef_steroid/main.reflectable.dart';
import 'package:ef_steroid/services/file/resource_group_key.dart';
import 'package:ef_steroid/services/log/log_service.dart';
import 'package:ef_steroid/services/service_locator.dart' as sl;
import 'package:ef_steroid/services/sqlite/sqlite_service.dart';
import 'package:ef_steroid/views/home/home_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;

Future<void> main() async {
  Logger.root.level = Level.ALL;
  WidgetsFlutterBinding.ensureInitialized();
  initializeReflectable();
  await sl.configure();

  Isolate.current.addErrorListener(
    RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;

      GetIt.I<LogService>().severe(
        'Error in isolate',
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort,
  );

  await runZonedGuarded(
    () async {
      await _handlerLogAsync();
      final setupSqliteService = _setupSqliteService();
      final setupAppSettings = AppSettings.instance.setup();
      final setupWindowMetrics = _setupWindowMetrics();
      await Future.wait([
        setupSqliteService,
        setupAppSettings,
        setupWindowMetrics,
      ]);

      DarqHelper.registerEqualityComparer();
      runApp(const HomeView());
    },
    (ex, stackTrace) async {
      GetIt.I<LogService>().severe(
        'Error in zone',
        ex,
        stackTrace,
      );
    },
  );
}

Future<void> _setupWindowMetrics() {
  return DesktopWindow.setMinWindowSize(const Size(400, 400));
}

Future<void> _handlerLogAsync() async {
  final applicationSupportDirectory =
      await path_provider.getApplicationSupportDirectory();
  final file = File(
    p.canonicalize(
      p.joinAll([
        applicationSupportDirectory.path,
        ResourceGroupKey.logs,
        // Windows path does not accept ':'.
        '${DateTime.now().toString().replaceAll(':', '')}_logs.txt',
      ]),
    ),
  );
  await file.create(recursive: true);
  final ioSink = file.openWrite(mode: FileMode.append);
  GetIt.I<LogService>().onRecord.listen((event) {
    var log = '[${event.level}] ${event.loggerName}: ${event.message}';
    if (event.error != null) {
      log += '\n ${event.error}';
      log += '\n ${event.stackTrace}';
    }
    if (kDebugMode) {
      print(log);
    }
    ioSink.write(log);
  });
}

Future<void> _setupSqliteService() async {
  GetIt.I<LogService>().info('Start setting up SqliteService');
  await GetIt.I<SqliteService>().setupAsync();
  GetIt.I<LogService>().info('Done setting up SqliteService');
}
