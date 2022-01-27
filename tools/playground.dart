import 'dart:io';

import 'package:path/path.dart' as p;

void main() {
  final filePath = p.canonicalize(p.joinAll([
    'D:/Users/',
    '123',
    '${DateTime.now().toString().replaceAll(':', '')}_logs.txt',
  ]));
  print(filePath);
  print(p.toUri(filePath).toFilePath(windows: true));


}
