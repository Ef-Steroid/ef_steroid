class ResolveDotnetEf6CommandNameException implements Exception {
  final String message;

  ResolveDotnetEf6CommandNameException({
    required this.message,
  });

  ResolveDotnetEf6CommandNameException.csprojFileNotFound({
    required Uri csprojUri,
  }) : this(message: 'csproj file: ${csprojUri.path} does not exist');

  ResolveDotnetEf6CommandNameException.invalidTargetFrameworkVersion({
    required String targetFrameworkVersion,
  }) : this(
          message: 'Invalid targetFrameworkVersion: $targetFrameworkVersion.',
        );

  ResolveDotnetEf6CommandNameException.invalidRuntimeTarget({
    required String platformTarget,
  }) : this(
          message:
              'Project has an active platform of $platformTarget. Select a different platform and try again.',
        );

  ResolveDotnetEf6CommandNameException.noEntityFrameworkPackageFound()
      : this(
          message: 'No entityFramework package found. Did you install it?',
        );

  /// An exception for EF6 in .NET Core project.
  ///
  /// Theoretically, Microsoft recommends to use EFCore for .Net Core project.
  /// See [this](https://docs.microsoft.com/en-us/aspnet/core/data/entity-framework-6?view=aspnetcore-6.0).
  ///
  /// However, if the community requests this feature, we can support it. There
  /// is an example provided [here](https://github.com/dotnet/AspNetCore.Docs/tree/main/aspnetcore/data/entity-framework-6/3.xsample)
  /// for FastDotnetEf that we can use to develop accordingly.
  ResolveDotnetEf6CommandNameException.unsupportedFramework()
      : this(message: 'EF6 for .Net Core is not supported.');
}
