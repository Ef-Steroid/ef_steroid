import 'package:collection/collection.dart' show IterableExtension;
import 'package:fast_dotnet_ef/data/default_values.dart';
import 'package:fast_dotnet_ef/domain/entity_dto.dart';
import 'package:fast_dotnet_ef/repository/repository.dart';
import 'package:fast_dotnet_ef/services/sqlite/sqlite_service.dart';
import 'package:fast_dotnet_ef/util/reflector.dart';
import 'package:get_it/get_it.dart';
import 'package:reflectable/reflectable.dart';

class AppRepository<TEntity extends EntityDto> extends Repository<TEntity> {
  final SqliteService _sqliteService = GetIt.I<SqliteService>();

  @override
  Future<int> insertOrUpdateAsync(TEntity entity) {
    return _sqliteService.useDatabaseAsync<int>(
      uow: (db) => entity.isTransient
          ? db.insert(
              getTableName(),
              entity.toJson(),
            )
          : db.update(
              getTableName(),
              entity.toJson(),
            ),
      orDefault: () => DefaultValues.intDefaultValue,
    );
  }

  @override
  Future<List<TEntity>> getAllAsync() {
    return _sqliteService.useReadonlyDatabaseAsync<List<TEntity>>(
      uow: (db) => db.query(getTableName()).then((value) {
        return value.map((e) => TEntity.fromJson<TEntity>(e)).toList();
      }),
      orDefault: () => [],
    );
  }

  @override
  Future<TEntity?> getAsync(int id) {
    return getAllAsync()
        .then((value) => value.firstWhereOrNull((element) => element.id == id));
  }

  @override
  Future<void> deleteAsync(TEntity entity) {
    return _sqliteService.useDatabaseAsync<void>(
      uow: (db) => db.delete(
        getTableName(),
        where: 'Id=?',
        whereArgs: [entity.id],
      ),
      orDefault: () {},
    );
  }
}

extension TypeExt on Type {
  T fromJson<T>(Map<String, dynamic> json) {
    return (reflector.reflectType(T) as ClassMirror).newInstance(
      'fromJson',
      [json],
    ) as T;
  }
}
