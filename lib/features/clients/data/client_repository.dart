import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/user_model.dart';
import '../../auth/data/auth_repository.dart';

class ClientPaginationResult {
  final List<User> clients;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  ClientPaginationResult({
    required this.clients,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });
}

class ClientRepository {
  final String baseUrl;
  final AuthRepository authRepo;

  ClientRepository({required this.baseUrl, required this.authRepo});

  Future<ClientPaginationResult> fetchClients({
    int page = 1,
    int pageSize = 8,
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
          final allClients =
              allData
                  .map((e) {
                    final userJson = Map<String, dynamic>.from(e);
                    userJson['username'] = e['name'];
                    return userJson;
                  })
                  .map((e) => User.fromJson(e))
                  .where((user) => user.role == 'CLIENT')
                  .toList();

          if (searchQuery != null && searchQuery.isNotEmpty) {
            allClients.removeWhere(
              (user) =>
                  !user.cin.toLowerCase().contains(searchQuery.toLowerCase()),
            );
          }

          totalCount = allClients.length;

          final startIndex = (page - 1) * pageSize;

          data =
              allClients
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

        final clients =
            data
                .map((e) {
                  final userJson = Map<String, dynamic>.from(e);
                  userJson['username'] = e['name'];
                  return userJson;
                })
                .map((e) => User.fromJson(e))
                .where((user) => user.role == 'CLIENT')
                .toList();

        final totalPages = (totalCount / pageSize).ceil();

        return ClientPaginationResult(
          clients: clients,
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

  Future<List<User>> fetchAllClients() async {
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
            .where((user) => user.role == 'CLIENT')
            .toList();
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getClientById(int clientId) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.get(
        Uri.parse('$baseUrl/api/users/get/$clientId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final dynamic responseData = json.decode(resp.body);

        if (responseData is List) {
          final clientData = responseData.firstWhere(
            (e) => e['id'] == clientId,
            orElse: () => throw Exception('Client not found'),
          );
          return User.fromJson(Map<String, dynamic>.from(clientData));
        } else if (responseData is Map<String, dynamic>) {
          return User.fromJson(responseData);
        }
        throw Exception('Invalid response format');
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createClient({
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
      Uri.parse('$baseUrl/api/users/clients/create/'),
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
        'role': 'CLIENT',
      }),
    );

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      final errorData = json.decode(resp.body);
      throw Exception('Create failed: ${errorData.toString()}');
    }
  }

  Future<void> updateClient({
    required int clientId,
    required String username,
    required String email,
    required String cin,
    required String tel,
    String? password,
  }) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final body = <String, dynamic>{
        'username': username,
        'email': email,
        'cin': cin,
        'tel': tel,
      };

      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final resp = await http.put(
        Uri.parse('$baseUrl/api/users/clients/$clientId/update/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode != 200) {
        final errorData = json.decode(resp.body);
        throw Exception('Update failed: ${errorData.toString()}');
      }
    } catch (e) {
      rethrow;
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

  Future<void> disactivateClient(int userId) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.patch(
        Uri.parse('$baseUrl/api/users/deactivate/$userId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode != 204 && resp.statusCode != 200) {
        final errorMessage =
            resp.statusCode == 404
                ? 'Client not found'
                : 'Disactivate failed: ${resp.body}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
