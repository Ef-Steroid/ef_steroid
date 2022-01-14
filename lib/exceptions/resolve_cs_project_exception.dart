class ResolveCsProjectException implements Exception {
  final String message;

  ResolveCsProjectException({
    required this.message,
  });

  ResolveCsProjectException.projectNotBuild({required String lookup})
      : this(
          message: 'Your project is not built. $lookup was not found.',
        );

  ResolveCsProjectException.projectAssetJsonParsingFailure({
    required String projectAssetJsonPath,
  }) : this(
          message:
              'Unable to parse project.assets.json. Please file an issue with your project.assets.json in $projectAssetJsonPath.',
        );

  @override
  String toString() {
    return message;
  }
}
