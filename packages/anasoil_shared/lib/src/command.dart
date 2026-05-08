import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);
typedef CommandAction2<T, A, B> = Future<Result<T>> Function(A, B);

/// Encapsulates an async UI operation with running/result state.
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  Result<T>? _result;

  bool get running => _running;
  bool get completed => _result is Ok<T>;
  bool get error => _result is Error<T>;
  Result<T>? get result => _result;

  /// Compatibility with code that expects a `.value` state object.
  CommandState<T> get value =>
      CommandState<T>(running: _running, result: _result);

  T? getCachedSuccess() {
    final r = _result;
    if (r is Ok<T>) return r.value;
    return null;
  }

  Exception? getCachedFailure() {
    final r = _result;
    if (r is Error<T>) return r.error;
    return null;
  }

  Future<void> _execute(Future<Result<T>> Function() action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } catch (e) {
      _result = Result.error(Exception(e.toString()));
    }

    _running = false;
    notifyListeners();
  }

  void clear() {
    _running = false;
    _result = null;
    notifyListeners();
  }
}

class CommandState<T> {
  final bool _running;
  final Result<T>? _result;

  const CommandState({required bool running, required Result<T>? result})
    : _running = running,
      _result = result;

  bool get isRunning => _running;
  bool get isFailure => _result is Error<T>;
  bool get isSuccess => _result is Ok<T>;
}

class Command0<T> extends Command<T> {
  final CommandAction0<T> _action;

  Command0(this._action);

  Future<void> execute() async {
    await _execute(() => _action());
  }
}

class Command1<T, A> extends Command<T> {
  final CommandAction1<T, A> _action;

  Command1(this._action);

  Future<void> execute(A arg) async {
    await _execute(() => _action(arg));
  }
}

class Command2<T, A, B> extends Command<T> {
  final CommandAction2<T, A, B> _action;

  Command2(this._action);

  Future<void> execute(A arg1, B arg2) async {
    await _execute(() => _action(arg1, arg2));
  }
}
