/*
 * Copyright 2022-2022 MOK KAH WAI and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

class ResolveDotnetEf6CommandNameException implements Exception {
  final String message;

  ResolveDotnetEf6CommandNameException({
    required this.message,
  });

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

  @override
  String toString() {
    return message;
  }
}
