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

@LazySingleton()
class AppLogService extends LogService {
  static final Map<Type, Logger> _loggers = {};

  final Type callerType;

  final List<LogRecord> _logs = [];

  AppLogService(
    @factoryParam this.callerType,
  ) {
    _loggers[callerType] = Logger(callerType.toString());
    onRecord.listen((event) {
      _logs.add(event);
    });
  }

  @override
  List<LogRecord> getLog() {
    return _logs;
  }

  @override
  Level get level => _getLogger().level;

  @override
  set level(Level? value) {
    _getLogger().level = value;
  }

  @override
  String get fullName => _getLogger().fullName;

  @override
  Map<String, Logger> get children => _getLogger().children;

  @override
  void clearListeners() {
    _getLogger().clearListeners();
  }

  @override
  void fine(Object? message, [Object? error, StackTrace? stackTrace]) {
    _getLogger().fine(message, error, stackTrace);
  }

  @override
  void config(Object? message, [Object? error, StackTrace? stackTrace]) {
    _getLogger().config(message, error, stackTrace);
  }

  @override
  void finer(Object? message, [Object? error, StackTrace? stackTrace]) {
    _getLogger().finer(message, error, stackTrace);
  }

  @override
  void finest(Object? message, [Object? error, StackTrace? stackTrace]) {
    _getLogger().finest(message, error, stackTrace);
  }

  @override
  void info(Object? message, [Object? error, StackTrace? stackTrace]) {
    _getLogger().info(message, error, stackTrace);
  }

  @override
  void severe(Object? message, [Object? error, StackTrace? stackTrace]) {
    _getLogger().severe(message, error, stackTrace);
  }

  @override
  void shout(Object? message, [Object? error, StackTrace? stackTrace]) {
    _getLogger().shout(message, error, stackTrace);
  }

  @override
  void warning(Object? message, [Object? error, StackTrace? stackTrace]) {
    _getLogger().warning(message, error, stackTrace);
  }

  @override
  bool isLoggable(Level value) {
    return _getLogger().isLoggable(value);
  }

  @override
  void log(
    Level logLevel,
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
    Zone? zone,
  ]) {
    _getLogger().log(
      logLevel,
      message,
      error,
      stackTrace,
      zone,
    );
  }

  @override
  String get name => _getLogger().name;

  @override
  Stream<LogRecord> get onRecord => _getLogger().onRecord;

  @override
  Logger? get parent => _getLogger().parent;

  Logger _getLogger() => _loggers[callerType]!;
}
