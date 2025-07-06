import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/user_model.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/models/product_model.dart';

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
    int pageSize = 10,
    String? searchQuery,
    String ordering = '-id', // Default to newest first (higher ID)
  }) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
        'ordering': ordering, // Add ordering parameter
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
          // Server-side pagination with ordering
          data = responseData['results'] as List<dynamic>;
          totalCount = responseData['count'] as int? ?? data.length;

          // Convert to User objects and filter for clients only
          final clients =
              data
                  .map((e) {
                    final userJson = Map<String, dynamic>.from(e);
                    userJson['username'] = e['name'];
                    return User.fromJson(userJson);
                  })
                  .where((user) => user.role == 'CLIENT')
                  .toList();

          return ClientPaginationResult(
            clients: clients,
            totalCount: totalCount,
            currentPage: page,
            totalPages: (totalCount / pageSize).ceil(),
          );
        } else {
          // Client-side pagination and ordering
          final allData = responseData as List<dynamic>;
          final allClients =
              allData
                  .map((e) {
                    final userJson = Map<String, dynamic>.from(e);
                    userJson['username'] = e['name'];
                    return User.fromJson(userJson);
                  })
                  .where((user) => user.role == 'CLIENT')
                  .toList();

          // Apply search filter first
          if (searchQuery != null && searchQuery.isNotEmpty) {
            allClients.removeWhere(
              (user) =>
                  !user.cin.toLowerCase().contains(searchQuery.toLowerCase()),
            );
          }

          // IMPORTANT: Sort by ID descending (newest first) - higher ID means newer
          allClients.sort((a, b) {
            if (ordering == '-id') {
              return b.id.compareTo(a.id); // Descending order (newest first)
            } else {
              return a.id.compareTo(b.id); // Ascending order (oldest first)
            }
          });

          totalCount = allClients.length;
          final startIndex = (page - 1) * pageSize;
          final endIndex = (startIndex + pageSize).clamp(0, allClients.length);

          // Get the paginated subset
          final paginatedClients = allClients.sublist(startIndex, endIndex);

          return ClientPaginationResult(
            clients: paginatedClients,
            totalCount: totalCount,
            currentPage: page,
            totalPages: (totalCount / pageSize).ceil(),
          );
        }
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> fetchAllClients({String ordering = '-id'}) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final queryParams = <String, String>{'ordering': ordering};

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
        if (responseData is Map && responseData.containsKey('results')) {
          data = responseData['results'] as List<dynamic>;
        } else {
          data = responseData as List<dynamic>;
        }

        final clients =
            data
                .map((e) {
                  final userJson = Map<String, dynamic>.from(e);
                  userJson['username'] = e['name'];
                  return User.fromJson(userJson);
                })
                .where((user) => user.role == 'CLIENT')
                .toList();

        // Always sort client-side to ensure proper ordering
        if (ordering == '-id') {
          clients.sort((a, b) => b.id.compareTo(a.id)); // Newest first
        } else {
          clients.sort((a, b) => a.id.compareTo(b.id)); // Oldest first
        }

        return clients;
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // Rest of your existing methods remain the same...
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
          final userJson = Map<String, dynamic>.from(clientData);
          userJson['username'] = clientData['name'];
          return User.fromJson(userJson);
        } else if (responseData is Map<String, dynamic>) {
          final userJson = Map<String, dynamic>.from(responseData);
          userJson['username'] = responseData['name'];
          return User.fromJson(userJson);
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
    try {
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
    } catch (e) {
      rethrow;
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
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'role': newRole}),
      );

      if (response.statusCode != 200) {
        throw Exception('Update failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
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

  Future<List<Product>> getClientProducts(String clientCin) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/api/products/?client=$clientCin'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data =
            responseData is Map
                ? (responseData['results'] ?? responseData['data'] ?? [])
                : responseData;

        if (data is! List) return [];

        return _parseProductsData(data, clientCin);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  List<Product> _parseProductsData(
    List<dynamic> responseData,
    String clientCin,
  ) {
    return responseData
        .map((item) {
          final productJson = Map<String, dynamic>.from(item);

          if (productJson['client'] == clientCin) {
            if (!productJson.containsKey('client_details')) {
              productJson['client_details'] = {
                'cin': clientCin,
                'username': productJson['client_name'] ?? 'Client $clientCin',
              };
            }
          }
          return Product.fromJson(productJson);
        })
        .where((product) => product.client == clientCin)
        .toList();
  }

  Future<dynamic> getClientByCin(String cin) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/search/$cin/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      return responseData['user'];
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception(
      'Failed to check client: ${response.statusCode} - ${response.body}',
    );
  }

  Future<int> fetchTotalClients() async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.get(
        Uri.parse('$baseUrl/api/users/total-clients/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        final responseData = json.decode(resp.body);
        return responseData['total_clients'] as int;
      }

      throw Exception('Failed to fetch total clients: ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
