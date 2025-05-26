import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/user_model.dart';
import '../../auth/data/auth_repository.dart';

class EmployeePaginationResult {
  final List<User> employees;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  EmployeePaginationResult({
    required this.employees,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });
}

class EmployeeRepository {
  final String baseUrl;
  final AuthRepository authRepo;

  EmployeeRepository({required this.baseUrl, required this.authRepo});

  Future<EmployeePaginationResult> fetchEmployees({
    int page = 1,
    int pageSize = 6,
    String? searchQuery,
  }) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['cin'] = searchQuery;
      }

      final uri = Uri.parse(
        '$baseUrl/api/users/get/',
      ).replace(queryParameters: queryParams);

      final resp = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final responseData = json.decode(resp.body);

        
        List<dynamic> data;
        int totalCount;

        if (responseData is Map && responseData.containsKey('results')) {
          
          data = responseData['results'] as List<dynamic>;
          totalCount = responseData['count'] as int? ?? data.length;
        } else {
          
          final allData = responseData as List<dynamic>;
          final allEmployees =
              allData
                  .map((e) {
                    final userJson = Map<String, dynamic>.from(e);
                    userJson['username'] = e['name'];
                    return userJson;
                  })
                  .map((e) => User.fromJson(e))
                  .where((user) => user.role == 'EMPLOYEE')
                  .toList();

          
          if (searchQuery != null && searchQuery.isNotEmpty) {
            allEmployees.removeWhere(
              (user) =>
                  !user.cin.toLowerCase().contains(searchQuery.toLowerCase()),
            );
          }

          totalCount = allEmployees.length;

          final startIndex = (page - 1) * pageSize;
          

          data =
              allEmployees
                  .skip(startIndex)
                  .take(pageSize)
                  .map(
                    (user) => {
                      'id': user.id,
                      'name': user.name,
                      'email': user.email,
                      'cin': user.cin,
                      'tel': user.tel,
                      'role': user.role,
                      'profile_photo': user.profileImageUrl,
                      'isActive': user.isActive,
                    },
                  )
                  .toList();
        }

        final employees =
            data
                .map((e) {
                  final userJson = Map<String, dynamic>.from(e);
                  userJson['username'] = e['name'];
                  return userJson;
                })
                .map((e) => User.fromJson(e))
                .where((user) => user.role == 'EMPLOYEE')
                .toList();

        final totalPages = (totalCount / pageSize).ceil();

        return EmployeePaginationResult(
          employees: employees,
          totalCount: totalCount,
          currentPage: page,
          totalPages: totalPages,
        );
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> fetchAllEmployees() async {
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
        'role': 'EMPLOYEE',
      }),
    );

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Create failed: ${resp.body}');
    }
  }

  Future<void> updateEmployee({
    required int id,
    required String username,
    required String email,
    String? password,
    required String cin,
    required String tel,
    required String role,
  }) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final Map<String, dynamic> requestBody = {
      'username': username,
      'email': email,
      'cin': cin,
      'tel': tel,
      'role': 'EMPLOYEE',
    };

    if (password != null && password.isNotEmpty) {
      requestBody['password'] = password;
    }

    final resp = await http.patch(
      Uri.parse('$baseUrl/api/users/employees-accountants/$id/update/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (resp.statusCode != 200) {
      final responseBody = resp.body;
      String errorMessage = 'Update failed';

      try {
        final errorData = json.decode(responseBody);
        if (errorData is Map<String, dynamic>) {
          // Extract specific field errors
          final errors = <String>[];
          errorData.forEach((key, value) {
            if (value is List) {
              errors.addAll(value.cast<String>());
            } else if (value is String) {
              errors.add(value);
            }
          });
          if (errors.isNotEmpty) {
            errorMessage = errors.join(', ');
          }
        }
      } catch (e) {
        // If we can't parse the error, use the raw response
        errorMessage = 'Update failed: $responseBody';
      }

      throw Exception(errorMessage);
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
