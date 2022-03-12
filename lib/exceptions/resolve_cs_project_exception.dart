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

class ResolveCsProjectException implements Exception {
  final String message;

  ResolveCsProjectException({
    required this.message,
  });

  ResolveCsProjectException.projectNotBuild({required String lookup})
      : this(
          message: 'Your project is not built. $lookup was not found.',
        );

  ResolveCsProjectException.projectAssetJsonParsingFailure({
    required String projectAssetJsonPath,
  }) : this(
          message:
              'Unable to parse project.assets.json. Please file an issue with your project.assets.json in $projectAssetJsonPath.',
        );

  @override
  String toString() {
    return message;
  }
}
