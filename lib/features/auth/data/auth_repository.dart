import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/utils/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/user_model.dart';

class AuthRepository {
  final String baseUrl;
  final TokenStorage _ts;

  AuthRepository({required this.baseUrl, SharedPreferences? sharedPreferences})
      : _ts = TokenStorage(sharedPreferences: sharedPreferences);

  // Add this static field to hold the current JWT token
  static String? currentToken;

  Future<String?> getAccessToken() => _ts.accessToken;
  Future<String?> getRefreshToken() => _ts.refreshToken;

  Future<bool> hasValidTokens() async {
    final accessToken = await _ts.accessToken;
    final refreshToken = await _ts.refreshToken;
    return accessToken != null && refreshToken != null;
  }

  Future<bool> validateAccessToken() async {
    try {
      final token = await _ts.accessToken;
      if (token == null) return false;

      final uri = Uri.parse('$baseUrl/api/users/me/');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<http.Response> _withAuth(
      Future<http.Response> Function(String token) fn,
      ) async {
    String? token = await _ts.accessToken;
    if (token == null) {
      throw Exception('No access token available');
    }

    var res = await fn(token);
    if (res.statusCode == 401) {
      final newToken = await refreshAccessToken();
      if (newToken != null) {
        res = await fn(newToken);
      } else {
        await _ts.clear();
        throw Exception('Authentication failed - please login again');
      }
    }
    return res;
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/login/');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await _ts.saveTokens(data['access'] as String, data['refresh'] as String);
      // Example: When you authenticate, set AuthRepository.currentToken = token;
      currentToken = data['access'] as String;
    } else {
      throw Exception('Auth failed (${res.statusCode}): ${res.body}');
    }
  }

  Future<void> logout() {
    // Example: When you logout, set AuthRepository.currentToken = null;
    currentToken = null;
    return _ts.clear();
  }

  Future<String?> refreshAccessToken() async {
    try {
      final refresh = await _ts.refreshToken;
      if (refresh == null || refresh.isEmpty) {
        return null;
      }

      final uri = Uri.parse('$baseUrl/api/auth/refresh/');

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final newAccess = data['access'] as String;

        final newRefresh = data['refresh'] as String? ?? refresh;

        await _ts.saveTokens(newAccess, newRefresh);
        return newAccess;
      } else if (res.statusCode == 401 || res.statusCode == 403) {


        await _ts.clear();
        return null;
      } else {
       
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<User> fetchCurrentUser() async {
    try {
      final uri = Uri.parse('$baseUrl/api/users/me/');
      final res = await _withAuth(
            (t) => http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $t',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        return User.fromJson(json);
      }

      throw Exception('Failed to fetch user (${res.statusCode}): ${res.body}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/auth/password/reset/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception(
        'Password-reset request failed '
            '(${resp.statusCode}): ${resp.body}',
      );
    }
  }

  Future<void> confirmPasswordReset(String token, String newPassword) async {
    final uri = Uri.parse('$baseUrl/api/auth/password/reset/confirm/');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'password': newPassword}),
    );

    if (resp.statusCode != 200 &&
        resp.statusCode != 204 &&
        resp.statusCode != 201) {
      throw Exception(
        'Failed to confirm password reset (${resp.statusCode}): ${resp.body}',
      );
    }
  }
}