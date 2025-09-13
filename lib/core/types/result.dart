/// Result type for better error handling and functional programming approach
///
/// This sealed class provides a type-safe way to handle operations that can succeed or fail.
/// It eliminates the need for throwing exceptions and provides better error handling.
sealed class Result<T, E> {
  const Result();

  /// Returns true if this is a [Success] result
  bool get isSuccess => this is Success<T, E>;

  /// Returns true if this is a [ResultFailure] result
  bool get isFailure => this is ResultFailure<T, E>;

  /// Returns the success data if available, null otherwise
  T? get data => switch (this) {
    Success(data: final data) => data,
    ResultFailure() => null,
  };

  /// Returns the error if this is a failure, null otherwise
  E? get error => switch (this) {
    Success() => null,
    ResultFailure(error: final error) => error,
  };

  /// Maps the success value to a new type
  Result<U, E> map<U>(U Function(T) mapper) {
    return switch (this) {
      Success(data: final data) => Success(mapper(data)),
      ResultFailure(error: final error) => ResultFailure(error),
    };
  }

  /// Maps the error to a new type
  Result<T, U> mapError<U>(U Function(E) mapper) {
    return switch (this) {
      Success(data: final data) => Success(data),
      ResultFailure(error: final error) => ResultFailure(mapper(error)),
    };
  }

  /// Executes the appropriate callback based on the result
  U when<U>({
    required U Function(T data) success,
    required U Function(E error) failure,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      ResultFailure(error: final error) => failure(error),
    };
  }
}

/// Represents a successful result with data
final class Success<T, E> extends Result<T, E> {
  const Success(this.data);

  final T data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> &&
      runtimeType == other.runtimeType &&
      data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// Represents a failed result with an error
final class ResultFailure<T, E> extends Result<T, E> {
  const ResultFailure(this.error);

  final E error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultFailure<T, E> &&
      runtimeType == other.runtimeType &&
      error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'ResultFailure(error: $error)';
}

// Convenience constructors for easier usage
typedef Failure<T, E> = ResultFailure<T, E>;