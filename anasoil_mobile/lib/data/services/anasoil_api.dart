import 'package:dio/dio.dart';
import '../../utils/result.dart';

/// Serviço centralizado de API para o AnaSoil
class AnaSoilApi {
  final Dio _dio;
  final String baseUrl;

  AnaSoilApi({required this.baseUrl, String? authToken})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (authToken != null) 'Authorization': 'Bearer $authToken',
          },
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log da requisição
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // Tratamento de erros globais
          if (error.response?.statusCode == 401) {
            // Token expirado - implementar refresh token aqui no futuro
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Atualiza o token de autenticação
  void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove o token de autenticação
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Login do usuário
  Future<Result<Map<String, dynamic>>> login(
    Map<String, dynamic> credentials,
  ) async {
    try {
      final response = await _dio.post('/auth/login', data: credentials);
      return Result.ok(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return Result.error(_handleDioError(e));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  /// Registro de novo usuário
  Future<Result<Map<String, dynamic>>> register(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('/auth/register', data: data);
      return Result.ok(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return Result.error(_handleDioError(e));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  /// Recuperação de senha
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _dio.post('/auth/reset-password', data: {'email': email});
      return Result.ok(null);
    } on DioException catch (e) {
      return Result.error(_handleDioError(e));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  /// Obter dados do usuário atual
  Future<Result<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return Result.ok(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return Result.error(_handleDioError(e));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  /// Logout
  Future<Result<void>> logout() async {
    try {
      await _dio.post('/auth/logout');
      return Result.ok(null);
    } on DioException catch (e) {
      return Result.error(_handleDioError(e));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  /// Tratamento de erros do Dio
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Tempo de conexão esgotado. Verifique sua internet.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] as String?;
        return Exception(message ?? 'Erro no servidor (código: $statusCode)');
      case DioExceptionType.cancel:
        return Exception('Requisição cancelada');
      default:
        return Exception('Erro de rede. Verifique sua conexão.');
    }
  }
}
