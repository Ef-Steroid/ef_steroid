import 'package:ef_steroid/repository/repository.dart';
import 'package:ef_steroid/services/service_locator.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@InjectableInit(preferRelativeImports: false)
Future<void> configure() async {
  $initGetIt(
    GetIt.instance,
  );

  Repository.registerRepositories();
}
