import 'package:ef_steroid/services/dotnet_ef/dotnet_ef_migration/dotnet_ef_migration_service.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

@Injectable(as: DotnetEfMigrationService)
class AppDotnetEfMigrationService extends DotnetEfMigrationService {
  AppDotnetEfMigrationService();

  @override
  Uri getMigrationsDirectory({
    required Uri projectUri,
  }) {
    return Uri.directory(
      p.joinAll([
        projectUri.toFilePath(),
        'Migrations',
      ]),
    );
  }
}
