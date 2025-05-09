// lib/features/auth/data/auth_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String baseUrl;
  AuthRepository({required this.baseUrl});

  /// Calls POST /api/auth/login/ with either "email" or "cin" + "password".
  Future<Map<String, dynamic>> login({
    required String email,
    required String cin,
    required String password,
  }) async {
    final body = <String, String>{};
    if (email.isNotEmpty) body['email'] = email;
    if (cin.isNotEmpty) body['cin'] = cin;
    body['password'] = password;

    final uri = Uri.parse('$baseUrl/api/auth/login/');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Authentication failed (${res.statusCode}): ${res.body}');
    }
  }

  Future<void> requestPasswordReset(String email) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/auth/password/reset/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Failed to request password reset');
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
