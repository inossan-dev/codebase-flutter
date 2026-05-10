import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:codebase/core/config/app_config.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/utils/app_logger.dart';

/// Clé de stockage du token JWT.
/// Définie ici pour éviter les magic strings dispersés dans le code.
const _kTokenKey = 'auth_token';

/// Client HTTP centralisé.
///
/// Responsabilités :
/// - Configuration de base (baseUrl, timeout)
/// - Injection automatique du Bearer token
/// - Refresh token transparent (interceptor)
/// - Mapping DioException → Failure (domaine)
/// - Logging des requêtes/réponses
final class DioClient {
  DioClient({Dio? dio, FlutterSecureStorage? storage})
    : _dio = dio ?? Dio(),
      _storage = storage ?? const FlutterSecureStorage() {
    _configure();
  }

  final Dio _dio;
  final FlutterSecureStorage _storage;

  Dio get instance => _dio;

  void _configure() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _dio),
      if (!AppConfig.isProduction) _LogInterceptor(),
    ]);
  }
}

// ─── Auth interceptor ────────────────────────────────────────────────────────

final class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage, this._dio);

  final FlutterSecureStorage _storage;
  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _kTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Refresh token si 401
    if (err.response?.statusCode == 401) {
      try {
        final newToken = await _refreshToken();
        await _storage.write(key: _kTokenKey, value: newToken);
        // Rejeu de la requête originale avec le nouveau token
        final opts = err.requestOptions
          ..headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(opts);
        return handler.resolve(response);
      } catch (_) {
        // Le refresh a échoué : forcer la déconnexion
        await _storage.delete(key: _kTokenKey);
        // TODO(auth): déclencher l'event de logout via un provider/stream
      }
    }
    handler.next(err);
  }

  Future<String> _refreshToken() async {
    // Implémenter ici l'appel au endpoint /auth/refresh
    throw UnimplementedError('refreshToken');
  }
}

// ─── Log interceptor ─────────────────────────────────────────────────────────

final class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.d('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    AppLogger.d('← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e(
      '✗ ${err.requestOptions.method} ${err.requestOptions.path}',
      err,
      err.stackTrace,
    );
    handler.next(err);
  }
}

// ─── DioException → Failure ──────────────────────────────────────────────────

/// Convertit les erreurs Dio en Failure du domaine.
/// À appeler dans les implémentations de repository (data layer).
Failure dioExceptionToFailure(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => const NetworkFailure(
      'Délai dépassé. Vérifiez votre connexion.',
    ),
    DioExceptionType.connectionError => const NetworkFailure(),
    DioExceptionType.badResponse => _statusToFailure(e.response?.statusCode),
    DioExceptionType.cancel => const UnexpectedFailure('Requête annulée.'),
    _ => const UnexpectedFailure(),
  };
}

Failure _statusToFailure(int? statusCode) => switch (statusCode) {
  401 => const UnauthorizedFailure(),
  403 => const ForbiddenFailure(),
  404 => const NotFoundFailure(),
  final code? when code >= 500 => const ServerFailure(),
  _ => const UnexpectedFailure(),
};
