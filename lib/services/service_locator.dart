import 'package:fast_dotnet_ef/repository/repository.dart';
import 'package:fast_dotnet_ef/services/service_locator.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@InjectableInit(preferRelativeImports: false)
Future<void> configure() async {
  $initGetIt(
    GetIt.instance,
  );

  Repository.registerRepositories();
}
