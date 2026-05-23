import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/config/network/dio_client.dart';
import 'package:smart_spend_app/features/auth/domain/auth_tokens.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._dio);

  final Dio _dio;

  Future<AuthTokens> loginWithGoogle(String idToken) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'provider': 'google', 'idToken': idToken},
    );
    return AuthTokens.fromJson(res.data!);
  }

  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _dio.post<void>(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }
}

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref.watch(plainDioProvider));
});
