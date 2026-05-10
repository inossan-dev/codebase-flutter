import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:codebase/core/utils/app_logger.dart';
import 'package:codebase/features/auth/data/models/user_model.dart';

const _kTokenKey = 'auth_token';
const _kUserKey = 'cached_user';

/// Datasource locale : persiste le token et le profil utilisateur.
///
/// flutter_secure_storage utilise :
/// - iOS    → Keychain
/// - Android → EncryptedSharedPreferences
///
/// Ne jamais stocker le token dans SharedPreferences (non chiffré).
final class AuthLocalDatasource {
  const AuthLocalDatasource(this._storage);

  final FlutterSecureStorage _storage;

  // ─── Token ────────────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _storage.write(key: _kTokenKey, value: token);
    AppLogger.d('Token saved to secure storage');
  }

  Future<String?> getToken() => _storage.read(key: _kTokenKey);

  Future<void> deleteToken() => _storage.delete(key: _kTokenKey);

  // ─── User cache ───────────────────────────────────────────────────────────

  Future<void> cacheUser(UserModel user) async {
    try {
      final encoded = jsonEncode(user.toJson());
      await _storage.write(key: _kUserKey, value: encoded);
    } catch (e, st) {
      // Ne pas planter si le cache échoue, juste logguer
      AppLogger.w('Failed to cache user', e, st);
    }
  }

  Future<UserModel?> getCachedUser() async {
    try {
      final raw = await _storage.read(key: _kUserKey);
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.w('Failed to read cached user, clearing cache', e, st);
      await _storage.delete(key: _kUserKey);
      return null;
    }
  }

  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _kTokenKey),
      _storage.delete(key: _kUserKey),
    ]);
    AppLogger.d('Local auth data cleared');
  }
}
