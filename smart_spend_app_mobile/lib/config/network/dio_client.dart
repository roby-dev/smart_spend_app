import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/config/env/app_env.dart';
import 'package:smart_spend_app/features/auth/data/token_storage.dart';
import 'package:smart_spend_app/features/auth/domain/auth_tokens.dart';

BaseOptions _baseOptions() => BaseOptions(
      baseUrl: AppEnv.backendBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      contentType: 'application/json',
    );

/// Dio without auth interceptor — used for /auth/login, /auth/refresh,
/// /auth/logout. Keeping it interceptor-free avoids refresh recursion.
final plainDioProvider = Provider<Dio>((ref) {
  return Dio(_baseOptions());
});

/// Dio for protected endpoints. Adds the access token and, on 401, attempts a
/// single token refresh before retrying the original request.
final authedDioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions());
  final storage = ref.watch(tokenStorageProvider);
  final plainDio = ref.watch(plainDioProvider);

  dio.interceptors.add(
    _AuthInterceptor(storage: storage, plainDio: plainDio, retryDio: dio),
  );
  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({
    required this.storage,
    required this.plainDio,
    required this.retryDio,
  });

  final TokenStorage storage;
  final Dio plainDio;
  final Dio retryDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final access = await storage.readAccessToken();
    if (access != null) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['__retried'] == true;

    if (!isUnauthorized || alreadyRetried) {
      return handler.next(err);
    }

    final refreshed = await _tryRefresh();
    if (!refreshed) {
      await storage.clear();
      return handler.next(err);
    }

    try {
      final access = await storage.readAccessToken();
      final options = err.requestOptions
        ..extra['__retried'] = true
        ..headers['Authorization'] = 'Bearer $access';
      final response = await retryDio.fetch<dynamic>(options);
      return handler.resolve(response);
    } catch (_) {
      return handler.next(err);
    }
  }

  Future<bool> _tryRefresh() async {
    final tokens = await storage.read();
    if (tokens == null) return false;
    try {
      final res = await plainDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': tokens.refreshToken},
        options: Options(
          headers: {'Authorization': 'Bearer ${tokens.accessToken}'},
        ),
      );
      final data = res.data;
      if (data == null) return false;
      await storage.save(
        AuthTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
