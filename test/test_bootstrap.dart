import 'dart:io';

import 'package:ef_steroid/services/log/log_service.dart';
import 'package:ef_steroid/services/service_locator.dart' as sl;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class TestBootstrap {
  static Future<void> runAsync() async {
    await sl.configure();
    GetIt.I<LogService>().onRecord.listen((event) {
      // ignore: avoid_print
      print(event);
    });
  }

  static Directory getProjectRootDirectory() {
    // This implementation takes advantage of the fact that Platform.script
    // returns `<Project root>/main.dart`.
    return File.fromUri(Platform.script).parent;
  }
}
