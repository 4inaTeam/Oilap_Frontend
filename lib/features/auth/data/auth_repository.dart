// lib/features/auth/data/auth_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/utils/token_storage.dart';

class AuthRepository {
  final String baseUrl;
  final TokenStorage _ts = TokenStorage();

  AuthRepository({required this.baseUrl});

  /// Perform login and save received tokens
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

  /// Clear tokens on logout
  Future<void> logout() async {
    await _ts.clear();
  }

  /// Refresh the access token using the stored refresh token
  Future<String?> refreshAccessToken() async {
    final refresh = await _ts.refreshToken;
    if (refresh == null) return null;

    final uri = Uri.parse('$baseUrl/api/token/refresh/');
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
    }

    return null;
  }

  /// Fetch current authenticated user data
  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final token = await _ts.accessToken;
    if (token == null) {
      throw Exception('No access token available');
    }

    final uri = Uri.parse('$baseUrl/api/users/me/');
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch user (${res.statusCode}): ${res.body}');
    }
  }

  /// Trigger password reset email
  Future<void> requestPasswordReset(String email) async {
    final resp = await http.post(
      Uri.parse('\$baseUrl/api/auth/password/reset/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception(
        'Password-reset request failed '
        '(\${resp.statusCode}): \${resp.body}',
      );
    }
  }

  /// Confirm a password reset using the token
  Future<void> confirmPasswordReset(String token, String newPassword) async {
    final uri = Uri.parse('\$baseUrl/api/auth/password/reset/confirm/');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'password': newPassword}),
    );

    if (resp.statusCode != 200 &&
        resp.statusCode != 204 &&
        resp.statusCode != 201) {
      throw Exception(
        'Failed to confirm password reset (\${resp.statusCode}): \${resp.body}',
      );
    }
  }
}
