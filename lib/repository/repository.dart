import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/domain/entity_dto.dart';
import 'package:ef_steroid/repository/app_repository.dart';
import 'package:ef_steroid/util/reflector.dart';
import 'package:get_it/get_it.dart';

abstract class Repository<TEntity extends EntityDto> {
  static const Map<Type, String> tables = {
    // EfPanel: EfPanel.tableName,
  };

  static void registerRepositories() {
    GetIt.I.registerFactory<Repository<EfPanel>>(
      () => AppRepository<EfPanel>(),
    );
  }

  String getTableName() {
    return '${reflector.reflectType(TEntity).simpleName}s';
  }

  Future<int> insertOrUpdateAsync(TEntity entity);

  Future<List<TEntity>> getAllAsync();

  Future<TEntity?> getAsync(int id);

  Future<void> deleteAsync(TEntity entity);
}
