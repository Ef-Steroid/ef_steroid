class ResolveCsprojException implements Exception {
  final String message;

  ResolveCsprojException({
    required this.message,
  });

  ResolveCsprojException.csprojFileNotFound({
    required Uri csprojUri,
  }) : this(message: 'csproj file: ${csprojUri.path} does not exist');

  @override
  String toString() {
    return message;
  }
}
