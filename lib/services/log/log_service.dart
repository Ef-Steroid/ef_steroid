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

import 'dart:async';

import 'package:logging/logging.dart';

abstract class LogService implements Logger {
  List<LogRecord> getLog();

  @override
  Level get level;

  @override
  set level(Level? value);

  @override
  Map<String, Logger> get children;

  @override
  String get fullName;

  @override
  String get name;

  @override
  Stream<LogRecord> get onRecord;

  @override
  Logger? get parent;

  @override
  void clearListeners();

  @override
  void fine(Object? message, [Object? error, StackTrace? stackTrace]);

  @override
  void config(Object? message, [Object? error, StackTrace? stackTrace]);

  @override
  void finer(Object? message, [Object? error, StackTrace? stackTrace]);

  @override
  void finest(Object? message, [Object? error, StackTrace? stackTrace]);

  @override
  void info(Object? message, [Object? error, StackTrace? stackTrace]);

  @override
  bool isLoggable(Level value);

  @override
  void log(
    Level logLevel,
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
    Zone? zone,
  ]);

  @override
  void severe(Object? message, [Object? error, StackTrace? stackTrace]);

  @override
  void shout(Object? message, [Object? error, StackTrace? stackTrace]);

  @override
  void warning(Object? message, [Object? error, StackTrace? stackTrace]);
}
