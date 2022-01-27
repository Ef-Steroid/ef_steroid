import 'dart:io';

import 'package:path/path.dart' as p;

extension FileSystemEntityExt on FileSystemEntity {
  String get fileName {
    return p.basename(path);
  }
}
