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

import 'package:ef_steroid/domain/entity_dto.dart';
import 'package:ef_steroid/repository/repository.dart';
import 'package:ef_steroid/repository_cache/repository_cache.dart';
import 'package:get_it/get_it.dart';

class AppRepositoryCache<TEntity extends EntityDto>
    extends RepositoryCache<TEntity> {
  final Map<int, TEntity> _cache = <int, TEntity>{};

  @override
  Future<TEntity> getAsync({
    required int id,
  }) =>
      tryGetAsync(id: id).then((value) => value!);

  @override
  Future<TEntity?> tryGetAsync({
    required int id,
  }) async {
    if (_cache.containsKey(id)) {
      return Future.value(_cache[id]);
    }

    final entity = await GetIt.I<Repository<TEntity>>().getAsync(id);
    if (entity == null) {
      return null;
    }

    _cache[entity.id!] = entity;
    return entity;
  }

  @override
  void delete({
    required int id,
  }) {
    _cache.remove(id);
  }
}
