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

  Future<String?> getAccessToken() => _ts.accessToken;
  Future<String?> getRefreshToken() => _ts.refreshToken;

  /// Check if we have valid tokens
  Future<bool> hasValidTokens() async {
    final accessToken = await _ts.accessToken;
    final refreshToken = await _ts.refreshToken;
    return accessToken != null && refreshToken != null;
  }

  /// Validate current access token by making a test request
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
      // Token expired, try to refresh
      final newToken = await refreshAccessToken();
      if (newToken != null) {
        // Retry the original request with new token
        res = await fn(newToken);
      } else {
        // Refresh failed, clear tokens and throw exception
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
    } else {
      throw Exception('Auth failed (${res.statusCode}): ${res.body}');
    }
  }

  Future<void> logout() => _ts.clear();

  Future<String?> refreshAccessToken() async {
    try {
      final refresh = await _ts.refreshToken;
      if (refresh == null || refresh.isEmpty) {
        print('No refresh token available');
        return null;
      }

      final uri = Uri.parse('$baseUrl/api/auth/refresh/');
      print('Attempting to refresh token...');

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      print('Refresh response status: ${res.statusCode}');
      print('Refresh response body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final newAccess = data['access'] as String;

        // Some APIs return a new refresh token, others keep the same one
        final newRefresh = data['refresh'] as String? ?? refresh;

        await _ts.saveTokens(newAccess, newRefresh);
        print('Tokens refreshed successfully');
        return newAccess;
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        // Refresh token is invalid/expired
        print('Refresh token expired or invalid');
        await _ts.clear();
        return null;
      } else {
        print('Unexpected refresh response: ${res.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error refreshing token: $e');
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
      print('Error fetching current user: $e');
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