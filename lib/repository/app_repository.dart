import 'package:fast_dotnet_ef/data/default_values.dart';
import 'package:fast_dotnet_ef/domain/entity_dto.dart';
import 'package:fast_dotnet_ef/repository/repository.dart';
import 'package:fast_dotnet_ef/services/log/log_service.dart';
import 'package:fast_dotnet_ef/services/sqlite/sqlite_service.dart';
import 'package:fast_dotnet_ef/util/reflector.dart';
import 'package:get_it/get_it.dart';
import 'package:reflectable/reflectable.dart';

class AppRepository<TEntity extends EntityDto> extends Repository<TEntity> {
  static const String _whereTemplate = 'Id=?';

  final SqliteService _sqliteService = GetIt.I<SqliteService>();
  final LogService _logService = GetIt.I<LogService>();

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
              entity.toUpdateJson(),
              where: _whereTemplate,
              whereArgs: [entity.id],
            ),
      orDefault: () => DefaultValues.intDefaultValue,
    );
  }

  @override
  Future<List<TEntity>> getAllAsync() async {
    _logService.info(
      'Start getting all entities: ${reflector.reflectType(TEntity).simpleName}',
    );
    final entities =
        await _sqliteService.useReadonlyDatabaseAsync<List<TEntity>>(
      uow: (db) => db.query(getTableName()).then((value) {
        return value.map((e) => TEntity.fromJson<TEntity>(e)).toList();
      }),
      orDefault: () => [],
    );
    _logService.info('Entities: ${entities.length}');
    return entities;
  }

  @override
  Future<TEntity?> getAsync(int id) {
    _logService.info(
      'Start getting entity: ${reflector.reflectType(TEntity).simpleName}',
    );

    return _sqliteService.useReadonlyDatabaseAsync<TEntity?>(
      uow: (db) {
        return db
            .query(
              getTableName(),
              where: _whereTemplate,
              whereArgs: [id],
              limit: 1,
            )
            .then((value) => TEntity.fromJson<TEntity>(value.first));
      },
      orDefault: () => null,
    );
  }

  @override
  Future<void> deleteAsync(TEntity entity) {
    return _sqliteService.useDatabaseAsync<void>(
      uow: (db) => db.delete(
        getTableName(),
        where: _whereTemplate,
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
