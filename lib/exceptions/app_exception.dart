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

/// This exception is intended to be thrown when user make client side error.
///
/// For example: input wrong email format
///
/// This exception should not be tracked in Crash Reporter
class UserFriendlyException implements Exception {
  final String message;

  UserFriendlyException(this.message);
}

/// The error that occurs due to server or system.
class AppError extends Error {
  final String message;

  AppError(this.message);

  @override
  String toString() {
    return 'AppError: $message';
  }
}
