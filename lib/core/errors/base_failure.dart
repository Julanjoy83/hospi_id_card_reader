/// Base class for all application failures
///
/// This provides a consistent way to handle errors across the application.
/// Each failure type includes a message and an optional error code for debugging.
abstract class Failure {
  const Failure({
    required this.message,
    this.code,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => 'Failure(message: $message, code: $code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
      runtimeType == other.runtimeType &&
      message == other.message &&
      code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}