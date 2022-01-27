/// Dotnet ef result type.
enum DotnetEfResultType {
  verbose,
  info,
  warn,
  error,
  data,
}

extension DotnetEfResultTypeExt on DotnetEfResultType {
  RegExp get dotnetEfResultRegex {
    switch (this) {
      case DotnetEfResultType.verbose:
        return RegExp('^verbose:');
      case DotnetEfResultType.info:
        return RegExp('^info:');
      case DotnetEfResultType.warn:
        return RegExp('^warn:');
      case DotnetEfResultType.error:
        return RegExp('^error:');
      case DotnetEfResultType.data:
        return RegExp('^data:');
    }
  }
}
