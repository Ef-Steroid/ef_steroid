// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:fast_dotnet_ef/services/dotnet_ef/app_dotnet_ef_service.dart'
    as _i6;
import 'package:fast_dotnet_ef/services/dotnet_ef/dotnet_ef_service.dart'
    as _i5;
import 'package:fast_dotnet_ef/services/log/app_log_service.dart' as _i4;
import 'package:fast_dotnet_ef/services/log/log_service.dart' as _i3;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart'
    as _i2; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.factory<_i3.LogService>(() => _i4.AppLogService());
  gh.factory<_i5.DotnetEfService>(
      () => _i6.AppDotnetEfService(get<_i3.LogService>()));
  return get;
}
