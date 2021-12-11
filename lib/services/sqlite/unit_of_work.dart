import 'package:sqflite/sqflite.dart';

typedef UnitOfWork<T> = Future<T> Function(Database db);

typedef DefaultResultAction<T> = T Function();
