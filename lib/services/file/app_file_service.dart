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
