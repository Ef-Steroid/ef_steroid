import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart';
import 'package:fast_dotnet_ef/services/file/file_service.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:injectable/injectable.dart';
import 'package:process_run/shell.dart';

@Injectable(as: DotnetEfService)
class AppDotnetEfService extends DotnetEfService {
  final LogService _logService;
  final FileService _fileService;

  static const String dotnetEfCommandName = 'dotnet-ef';

  AppDotnetEfService(
    this._logService,
    this._fileService,
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

    final args = <String>[];

    // Add database command.
    args.add('database');

    // Add update command.
    args.add('update');

    // Add project option.
    args.add('-p');
    var projectPath = Uri.decodeFull(projectUri.toString());

    projectPath = _fileService.stripMacDiscFromPath(path: projectPath);

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
