import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Result.ok carries a typed value', () {
    final result = Result.ok(42);

    expect(result, isA<Ok<int>>());
    expect((result as Ok<int>).value, 42);
  });

  test('Result.error carries an exception', () {
    final error = Exception('boom');
    final result = Result<int>.error(error);

    expect(result, isA<Error<int>>());
    expect((result as Error<int>).error, error);
  });
}
