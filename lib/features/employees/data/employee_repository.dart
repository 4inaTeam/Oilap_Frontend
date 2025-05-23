import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/user_model.dart';
import '../../auth/data/auth_repository.dart';

class EmployeeRepository {
  final String baseUrl;
  final AuthRepository authRepo;

  EmployeeRepository({required this.baseUrl, required this.authRepo});

  Future<List<User>> fetchEmployees() async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.get(
        Uri.parse('$baseUrl/api/users/get/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);

        return data
            .map((e) {
              final userJson = Map<String, dynamic>.from(e);
              userJson['username'] = e['name'];
              return userJson;
            })
            .map((e) => User.fromJson(e))
            .where((user) => user.role == 'EMPLOYEE')
            .toList();
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createEmployee({
    required String username,
    required String email,
    required String password,
    required String cin,
    required String tel,
    required String role,
  }) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

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

  Future<void> updateRole(int userId, String newRole) async {
    final token = await authRepo.getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/$userId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'role': newRole}),
    );
    if (response.statusCode != 200) throw Exception('Update failed');
  }

  Future<void> deleteEmployee(int userId) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final resp = await http.delete(
      Uri.parse('$baseUrl/api/users/delete/$userId/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode != 204) {
      throw Exception('Delete failed: ${resp.body}');
    }
  }
}
