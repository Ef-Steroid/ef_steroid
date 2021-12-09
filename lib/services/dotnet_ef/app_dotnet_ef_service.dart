import 'dart:io';

import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:injectable/injectable.dart';
import 'package:process_run/shell.dart';

@Injectable(as: DotnetEfService)
class AppDotnetEfService extends DotnetEfService {
  final LogService _logService;

  static const String dotnetEfCommandName = 'dotnet-ef';

  AppDotnetEfService(
    this._logService,
  );

  String get dotnetEfExecutable {
    final executable = whichSync(dotnetEfCommandName);
    if (executable == null) {
      throw Exception(
          'Unable to locate $dotnetEfCommandName. Did you install it?');
    }
    return executable;
  }

  @override
  Future<String> updateDatabaseAsync({
    required Uri projectUri,
  }) async {
    const stdin = Stream<List<int>>.empty();
    final shell = Shell(
      stdin: stdin,
      commandVerbose: true,
      commentVerbose: true,
    );
    stdin.listen((event) {
      print(event);
    });
    final args = <String>[];

    // Add database command.
    args.add('database');

    // Add update command.
    args.add('update');

    // Add project option.
    args.add('-p');
    var projectPath = Uri.decodeFull(projectUri.toString());

    if (Platform.isMacOS) {
      final homeSegment = Platform.environment['HOME']!;
      final matches = homeSegment.allMatches(projectPath);
      if (matches.isNotEmpty) {
        projectPath = projectPath.substring(matches.first.start);
      }
    }

    args.add(projectPath);
    String? result;
    try {
      final processResult = await shell.runExecutableArguments(
        dotnetEfExecutable,
        args,
      );

      result = processResult.stdout;
    } on ShellException catch (ex, stackTrace) {
      _logService.severe(
        'Unable to execute command: ${ex.message}',
        ex,
        stackTrace,
      );
    } catch (ex, stackTrace) {
      _logService.severe(
        'Unable to execute command.',
        ex,
        stackTrace,
      );
    }

    return result ?? '';
  }
}
