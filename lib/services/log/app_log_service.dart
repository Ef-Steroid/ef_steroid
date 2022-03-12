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

import 'package:ef_steroid/services/log/log_service.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

@LazySingleton(as: LogService)
class AppLogService extends LogService {
  final List<LogRecord> _logs = [];

  AppLogService() {
    onRecord.listen((event) {
      _logs.add(event);
    });
  }

  @override
  List<LogRecord> getLog() {
    return _logs;
  }

  @override
  Level get level => Logger.root.level;

  @override
  set level(Level? value) {
    Logger.root.level = value;
  }

  @override
  String get fullName => Logger.root.fullName;

  @override
  Map<String, Logger> get children => Logger.root.children;

  @override
  void clearListeners() {
    Logger.root.clearListeners();
  }

  @override
  void fine(Object? message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.fine(message, error, stackTrace);
  }

  @override
  void config(Object? message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.config(message, error, stackTrace);
  }

  @override
  void finer(Object? message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.finer(message, error, stackTrace);
  }

  @override
  void finest(Object? message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.finest(message, error, stackTrace);
  }

  @override
  void info(Object? message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.info(message, error, stackTrace);
  }

  @override
  void severe(Object? message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.severe(message, error, stackTrace);
  }

  @override
  void shout(Object? message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.shout(message, error, stackTrace);
  }

  @override
  void warning(Object? message, [Object? error, StackTrace? stackTrace]) {
    Logger.root.warning(message, error, stackTrace);
  }

  @override
  bool isLoggable(Level value) {
    return Logger.root.isLoggable(value);
  }

  @override
  void log(
    Level logLevel,
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
    Zone? zone,
  ]) {
    Logger.root.log(
      logLevel,
      message,
      error,
      stackTrace,
      zone,
    );
  }

  @override
  String get name => Logger.root.name;

  @override
  Stream<LogRecord> get onRecord => Logger.root.onRecord;

  @override
  Logger? get parent => Logger.root.parent;
}
