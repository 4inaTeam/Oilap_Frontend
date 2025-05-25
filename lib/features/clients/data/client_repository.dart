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

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['cin'] = searchQuery;
      }

      final uri = Uri.parse('$baseUrl/api/users/get/').replace(
        queryParameters: queryParams,
      );

      final resp = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final responseData = json.decode(resp.body);

        // Handle both paginated and non-paginated responses
        List<dynamic> data;
        int totalCount;

        if (responseData is Map && responseData.containsKey('results')) {
          // Paginated response
          data = responseData['results'] as List<dynamic>;
          totalCount = responseData['count'] as int? ?? data.length;
        } else {
          // Non-paginated response - filter client-side
          final allData = responseData as List<dynamic>;
          final allClients = allData
              .map((e) {
            final userJson = Map<String, dynamic>.from(e);
            userJson['username'] = e['name'];
            return userJson;
          })
              .map((e) => User.fromJson(e))
              .where((user) => user.role == 'CLIENT')
              .toList();

          // Apply search filter
          if (searchQuery != null && searchQuery.isNotEmpty) {
            allClients.removeWhere((user) =>
            !user.cin.toLowerCase().contains(searchQuery.toLowerCase()));
          }

          totalCount = allClients.length;

          // Apply pagination
          final startIndex = (page - 1) * pageSize;
          //final endIndex = startIndex + pageSize;

          data = allClients
              .skip(startIndex)
              .take(pageSize)
              .map((user) => {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'cin': user.cin,
            'tel': user.tel,
            'role': user.role,
            'profile_photo': user.profileImageUrl,
            'isActive': user.isActive,
          })
              .toList();
        }

        final clients = data
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
        'role': 'CLIENT',
      }),
    );

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Create failed: ${resp.body}');
    }
  }

  Future<void> updateRole(int userId, String newRole) async {
    final token = await authRepo.getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/clients/$userId/update/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'role': newRole}),
    );
    if (response.statusCode != 200) throw Exception('Update failed');
  }

  Future<void> deleteClient(int userId) async {
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