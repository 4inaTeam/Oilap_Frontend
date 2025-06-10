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

  // Static fields to hold the current JWT token and role
  static String? currentToken;
  static String? currentRole;

  // Helper to extract role from JWT token with detailed debugging
  static String? extractRoleFromToken(String? token) {
    if (token == null) {
      print('DEBUG: Token is null');
      return null;
    }
    
    try {
      print('DEBUG: Token: ${token.substring(0, 50)}...'); // Print first 50 chars
      
      final parts = token.split('.');
      if (parts.length != 3) {
        print('DEBUG: Invalid JWT format - parts length: ${parts.length}');
        return null;
      }
      
      print('DEBUG: JWT parts count: ${parts.length}');
      
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      
      print('DEBUG: Decoded payload: $payload');
      
      final payloadMap = json.decode(payload);
      print('DEBUG: Payload map: $payloadMap');
      print('DEBUG: Available keys: ${payloadMap.keys.toList()}');
      
      // Check for different possible role field names
      String? role;
      
      // Common role field names in JWT tokens
      final possibleRoleFields = ['role', 'roles', 'user_role', 'userRole', 'authority', 'authorities', 'permissions', 'groups'];
      
      for (String field in possibleRoleFields) {
        if (payloadMap.containsKey(field)) {
          print('DEBUG: Found role field "$field": ${payloadMap[field]}');
          role = payloadMap[field] as String?;
          if (role != null) break;
        }
      }
      
      if (role == null) {
        print('DEBUG: No role field found in token payload');
        print('DEBUG: Full payload structure: ${payloadMap.toString()}');
      } else {
        print('DEBUG: Extracted role: $role');
      }
      
      return role;
    } catch (e) {
      print('DEBUG: Error extracting role from token: $e');
      return null;
    }
  }

  // Initialize the static variables when the app starts
  Future<void> initializeAuth() async {
    final token = await _ts.accessToken;
    if (token != null) {
      print('DEBUG: Initializing auth with existing token');
      currentToken = token;
      currentRole = extractRoleFromToken(token);
      print('DEBUG: Initialized role: $currentRole');
    } else {
      print('DEBUG: No existing token found during initialization');
    }
  }

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
        // Update static variables after successful refresh
        currentToken = newToken;
        currentRole = extractRoleFromToken(newToken);
      } else {
        await _ts.clear();
        currentToken = null;
        currentRole = null;
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

    print('DEBUG: Login response status: ${res.statusCode}');
    print('DEBUG: Login response body: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      print('DEBUG: Login response data: $data');
      
      final accessToken = data['access'] as String;
      final refreshToken = data['refresh'] as String;
      
      await _ts.saveTokens(accessToken, refreshToken);
      
      // Update static variables
      currentToken = accessToken;
      currentRole = extractRoleFromToken(accessToken);
      
      print('DEBUG: Login successful. Role: $currentRole');
    } else {
      throw Exception('Auth failed (${res.statusCode}): ${res.body}');
    }
  }

  Future<void> logout() {
    // Clear static variables
    currentToken = null;
    currentRole = null;
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
        
        // Update static variables
        currentToken = newAccess;
        currentRole = extractRoleFromToken(newAccess);
        
        return newAccess;
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        await _ts.clear();
        currentToken = null;
        currentRole = null;
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
        print('DEBUG: User data from API: $json');
        
        // Check if role is in the user data instead of JWT
        if (json.containsKey('role')) {
          print('DEBUG: Found role in user data: ${json['role']}');
          currentRole = json['role'] as String?;
        }
        
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