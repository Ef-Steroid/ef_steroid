import 'dart:convert';
import 'dart:io';

import 'package:fast_dotnet_ef/services/dotnet_ef_service.dart';
import 'package:process_run/shell.dart';

class AppDotnetEfService extends DotnetEfService {
  static final runInShell = Platform.isWindows ? true : false;

  static const String dotnetEfCommandName = 'dotnet-ef';

  String get dotnetEfExecutable {
    final executable = whichSync(dotnetEfCommandName);
    if (executable == null) {
      throw Exception(
          'Unable to locate $dotnetEfCommandName. Did you install it?');
    }
    return executable;
  }

  @override
  Future<void> updateDatabaseAsync() async {
    final shell = Shell(
      runInShell: runInShell,
    );

    final processResult = await shell.runExecutableArguments(
      dotnetEfExecutable,
      [],
    );

    print(processResult.stdout);
  }
}
