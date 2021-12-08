import 'dart:async';

import 'package:fast_dotnet_ef/services/log/log_service.dart';
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
