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
