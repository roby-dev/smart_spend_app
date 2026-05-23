import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_spend_app/features/auth/domain/auth_tokens.dart';
import 'package:smart_spend_app/features/auth/domain/user_profile.dart';

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccess = 'ss_access_token';
  static const _kRefresh = 'ss_refresh_token';
  static const _kProfile = 'ss_user_profile';

  Future<void> save(AuthTokens tokens) async {
    await _storage.write(key: _kAccess, value: tokens.accessToken);
    await _storage.write(key: _kRefresh, value: tokens.refreshToken);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _storage.write(key: _kProfile, value: jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> readProfile() async {
    final raw = await _storage.read(key: _kProfile);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<AuthTokens?> read() async {
    final access = await _storage.read(key: _kAccess);
    final refresh = await _storage.read(key: _kRefresh);
    if (access == null || refresh == null) return null;
    return AuthTokens(accessToken: access, refreshToken: refresh);
  }

  Future<String?> readAccessToken() => _storage.read(key: _kAccess);

  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kProfile);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});
