import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _keyAccess = 'ACCESS_TOKEN';
  static const _keyRefresh = 'REFRESH_TOKEN';

  final FlutterSecureStorage? _secureStorage;
  final SharedPreferences? _sharedPreferences;

  TokenStorage({SharedPreferences? sharedPreferences})
    : _secureStorage = kIsWeb ? null : const FlutterSecureStorage(),
      _sharedPreferences = sharedPreferences;

  Future<void> saveTokens(String access, String refresh) async {
    if (kIsWeb) {
      await _sharedPreferences?.setString(_keyAccess, access);
      await _sharedPreferences?.setString(_keyRefresh, refresh);
    } else {
      await _secureStorage?.write(key: _keyAccess, value: access);
      await _secureStorage?.write(key: _keyRefresh, value: refresh);
    }
  }

  Future<String?> get accessToken async {
    if (kIsWeb) {
      return _sharedPreferences?.getString(_keyAccess);
    } else {
      return await _secureStorage?.read(key: _keyAccess);
    }
  }

  Future<String?> get refreshToken async {
    if (kIsWeb) {
      return _sharedPreferences?.getString(_keyRefresh);
    } else {
      return await _secureStorage?.read(key: _keyRefresh);
    }
  }

  Future<void> clear() async {
    if (kIsWeb) {
      await _sharedPreferences?.remove(_keyAccess);
      await _sharedPreferences?.remove(_keyRefresh);
    } else {
      await _secureStorage?.delete(key: _keyAccess);
      await _secureStorage?.delete(key: _keyRefresh);
    }
  }
}
