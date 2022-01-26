import 'dart:io';

import 'package:ef_steroid/services/file/file_service.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: FileService)
class AppFileService extends FileService {
  @override
  String stripMacDiscFromPath({
    required String path,
  }) {
    if (!Platform.isMacOS) return path;

    final homeSegment = Platform.environment['HOME']!;
    final matches = homeSegment.allMatches(path);
    if (matches.isNotEmpty) {
      path = path.substring(matches.first.start);
    }

    return path;
  }
}
