import 'package:fast_dotnet_ef/data/default_values.dart';
import 'package:fast_dotnet_ef/domain/entity_dto.dart';
import 'package:fast_dotnet_ef/repository/repository.dart';
import 'package:fast_dotnet_ef/services/sqlite/sqlite_service.dart';
import 'package:get_it/get_it.dart';

class AppRepository<TEntity extends EntityDto> extends Repository<TEntity> {
  final SqliteService _sqliteService = GetIt.I<SqliteService>();

  @override
  Future<int> insertOrUpdateAsync(TEntity entity) {
    return _sqliteService.useDatabaseAsync<int>(
      uow: (db) {
        return entity.isTransient
            ? db.insert(
                Repository.tables[TEntity]!,
                entity.toJson(),
              )
            : db.update(
                Repository.tables[TEntity]!,
                entity.toJson(),
              );
      },
      orDefault: () => DefaultValues.intDefaultValue,
    );
  }
}
