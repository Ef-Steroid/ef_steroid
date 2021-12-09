import 'package:sqflite/sqflite.dart';

abstract class SqliteService {
  Database get database;

  Future<void> setupAsync();
}
