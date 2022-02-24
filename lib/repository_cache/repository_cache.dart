import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/domain/entity_dto.dart';
import 'package:ef_steroid/repository_cache/app_repository_cache.dart';
import 'package:get_it/get_it.dart';

abstract class RepositoryCache<TEntity extends EntityDto> {
  static void registerRepositoryCache() {
    GetIt.I.registerSingleton<RepositoryCache<EfPanel>>(
      AppRepositoryCache<EfPanel>(),
    );
  }

  /// Get cache for [id].
  ///
  /// Throw [Error] if not found.
  Future<TEntity> getAsync({
    required int id,
  });

  /// Get cache for [id].
  ///
  /// Return null if not found.
  Future<TEntity?> tryGetAsync({
    required int id,
  });

  /// Delete the cache for [id].
  void delete({required int id});
}
