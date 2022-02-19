import 'package:ef_steroid/services/sqlite/unit_of_work.dart';

abstract class SqliteService {
  /// The path to the database.
  String get dbPath;

  /// Setup the database.
  ///
  /// This will update the migration.
  Future<void> setupAsync();

  /// Open a database and close it after usage.
  Future<T> useDatabaseAsync<T>({
    required UnitOfWork<T> uow,
    required DefaultResultAction<T> orDefault,
  });

  /// Open a readonly database and close it after usage.
  Future<T> useReadonlyDatabaseAsync<T>({
    required UnitOfWork<T> uow,
    required DefaultResultAction<T> orDefault,
  });
}
