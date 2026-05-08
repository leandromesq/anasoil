/// Sealed class for functional error handling without throwing through app layers.
sealed class Result<T> {
  const Result();

  factory Result.ok(T value) = Ok._;
  factory Result.error(Exception error) = Error._;
}

/// Successful result.
final class Ok<T> extends Result<T> {
  final T value;
  const Ok._(this.value);
}

/// Failed result.
final class Error<T> extends Result<T> {
  final Exception error;
  const Error._(this.error);
}
