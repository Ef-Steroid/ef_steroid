import 'package:fast_dotnet_ef/services/dotnet_ef/ef_model/migration_history.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_operation/ef_operation_view_model_base.dart';

class Ef6OperationViewModel extends EfOperationViewModelBase {
  Ef6OperationViewModel();

  @override
  Future<void> listMigrationsAsync() {
    // TODO: implement listMigrationsAsync
    throw UnimplementedError();
  }

  @override
  Future<void> removeMigrationAsync({
    required bool force,
  }) {
    // TODO: implement removeMigrationAsync
    throw UnimplementedError();
  }

  @override
  Future<void> updateDatabaseToTargetedMigrationAsync({
    required MigrationHistory migrationHistory,
  }) {
    // TODO: implement updateDatabaseToTargetedMigrationAsync
    throw UnimplementedError();
  }

  @override
  Future<void> addMigrationAsync() {
    // TODO: implement addMigrationAsync
    throw UnimplementedError();
  }
}
