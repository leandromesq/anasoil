import 'package:flutter/foundation.dart';
import 'result.dart';

/// Tipo de ação para Command sem parâmetros
typedef CommandAction0<T> = Future<Result<T>> Function();

/// Tipo de ação para Command com 1 parâmetro
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);

/// Base abstrata para Commands que encapsulam operações assíncronas com estado
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  Result<T>? _result;

  /// Se o command está executando
  bool get running => _running;

  /// Se o command completou com sucesso
  bool get completed => _result is Ok;

  /// Se o command completou com erro
  bool get error => _result is Error;

  /// Resultado da execução (Ok ou Error)
  Result<T>? get result => _result;

  /// Executa a operação
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

  /// Limpa o estado do command
  void clear() {
    _running = false;
    _result = null;
    notifyListeners();
  }
}

/// Command sem parâmetros
class Command0<T> extends Command<T> {
  final CommandAction0<T> _action;

  Command0(this._action);

  Future<void> execute() async {
    await _execute(() => _action());
  }
}

/// Command com 1 parâmetro
class Command1<T, A> extends Command<T> {
  final CommandAction1<T, A> _action;

  Command1(this._action);

  Future<void> execute(A arg) async {
    await _execute(() => _action(arg));
  }
}
