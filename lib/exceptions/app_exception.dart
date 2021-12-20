/// This exception is intended to be thrown when user make client side error.
///
/// For example: input wrong email format
///
/// This exception should not be tracked in Crash Reporter
class UserFriendlyException implements Exception {
  final String message;

  UserFriendlyException(this.message);
}

/// The error that occurs due to server or system.
class AppError extends Error {
  final String message;

  AppError(this.message);

  @override
  String toString() {
    return 'AppError: $message';
  }
}
