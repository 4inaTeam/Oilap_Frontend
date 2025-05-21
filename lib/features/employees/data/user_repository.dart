import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class UserRepository {
  final String baseUrl;
  final String token;
  UserRepository({required this.baseUrl, required this.token});

  Future<List<User>> fetchEmployees() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/users/get/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) throw Exception('Failed to load');
    final list = jsonDecode(resp.body) as List;
    return list.map((e) => User.fromJson(e)).toList();
  }

  Future<void> createEmployee({
    required String username,
    required String email,
    required String password,
    required String cin,
    required String tel,
    required String role,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/users/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'cin': cin,
        'tel': tel,
        'role': role == 'Comptable' ? 'ACCOUNTANT' : 'EMPLOYEE',
      }),
    );
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Create failed: ${resp.body}');
    }
  }
}
