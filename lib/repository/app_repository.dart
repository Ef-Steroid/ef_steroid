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

import 'package:ef_steroid/data/default_values.dart';
import 'package:ef_steroid/domain/entity_dto.dart';
import 'package:ef_steroid/repository/repository.dart';
import 'package:ef_steroid/services/log/log_service.dart';
import 'package:ef_steroid/services/sqlite/sqlite_service.dart';
import 'package:ef_steroid/util/reflector.dart';
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
