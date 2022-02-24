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
