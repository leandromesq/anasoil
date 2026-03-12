/// Sealed class para tratamento funcional de erros sem exceptions
sealed class Result<T> {
  const Result();

  factory Result.ok(T value) = Ok._;
  factory Result.error(Exception error) = Error._;
}

/// Resultado de sucesso
final class Ok<T> extends Result<T> {
  final T value;
  const Ok._(this.value);
}

/// Resultado de erro
final class Error<T> extends Result<T> {
  final Exception error;
  const Error._(this.error);
}
