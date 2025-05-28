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
                      'profile_photo': user.profilePhotoUrl,
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

  List<Product> _parseProductsData(List<dynamic> responseData, String clientCin) {
    print('Parsing ${responseData.length} products for client $clientCin');

    final products =
        responseData
            .map<Product?>((item) {
              try {
                final productJson = Map<String, dynamic>.from(item);

                // Debug: Print raw product data
                print('Raw product data: $productJson');

                final product = Product.fromJson(productJson);

                // Debug: Print parsed product
                print(
                  'Parsed product: ID=${product.id}, clientCin=${product.clientCin}, clientId=${product.clientId}',
                );

                return product;
              } catch (e) {
                print('Error parsing product: $e, Data: $item');
                return null;
              }
            })
            .where((product) => product != null)
            .cast<Product>()
            .toList();

    print('Parsed ${products.length} total products');

    // Filter products for the specific client
    final clientProducts =
        products.where((product) {
          final matchesClient = product.clientCin == clientCin;
          print(
            'Product ${product.id} matches clientCin $clientCin: $matchesClient (clientCin: ${product.clientCin}, clientId: ${product.clientId})',
          );
          return matchesClient;
        }).toList();

    print('Filtered ${clientProducts.length} products for client $clientCin');
    return clientProducts;
  }

  Future<List<Product>> getClientProducts(String clientCin) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      print('Fetching products for client CIN: $clientCin');

      // Try the specific endpoint first
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/products/admin/client-products/$clientCin/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('Specific endpoint - Status: ${response.statusCode}');
        print('Specific endpoint - Body: ${response.body}');

        if (response.statusCode == 200) {
          final responseBody = response.body.trim();
          if (responseBody.isEmpty) {
            print('Empty response body from specific endpoint');
            return [];
          }

          final dynamic responseData = json.decode(responseBody);

          if (responseData is List) {
            return _parseProductsData(responseData, clientCin);
          } else if (responseData is Map &&
              responseData.containsKey('results')) {
            return _parseProductsData(responseData['results'], clientCin);
          } else if (responseData is Map && responseData.containsKey('data')) {
            return _parseProductsData(responseData['data'], clientCin);
          } else {
            print(
              'Unexpected response format from specific endpoint: ${responseData.runtimeType}',
            );
            // Don't return empty, try fallback
          }
        } else {
          print('Specific endpoint failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Specific endpoint error: $e');
      }

      // Fallback to general endpoint
      print('Trying fallback: general products endpoint');

      final fallbackResponse = await http.get(
        Uri.parse('$baseUrl/api/products/client/products/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Fallback endpoint - Status: ${fallbackResponse.statusCode}');

      if (fallbackResponse.statusCode == 200) {
        final responseBody = fallbackResponse.body.trim();
        if (responseBody.isEmpty) {
          print('Empty response body from fallback endpoint');
          return [];
        }

        final dynamic responseData = json.decode(responseBody);

        if (responseData is List) {
          return _parseProductsData(responseData, clientCin);
        } else if (responseData is Map && responseData.containsKey('results')) {
          return _parseProductsData(responseData['results'], clientCin);
        } else {
          print(
            'Unexpected response format from fallback endpoint: ${responseData.runtimeType}',
          );
          return [];
        }
      }

      // Final fallback - try to get all products and filter client-side
      print('Trying final fallback: all products endpoint');

      final allProductsResponse = await http.get(
        Uri.parse('$baseUrl/api/products/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (allProductsResponse.statusCode == 200) {
        final responseBody = allProductsResponse.body.trim();
        if (responseBody.isEmpty) return [];

        final dynamic responseData = json.decode(responseBody);

        if (responseData is List) {
          return _parseProductsData(responseData, clientCin);
        } else if (responseData is Map && responseData.containsKey('results')) {
          return _parseProductsData(responseData['results'], clientCin);
        }
      }

      throw Exception('All endpoints failed to fetch products');
    } catch (e) {
      print('Error in getClientProducts for client $clientCin: $e');
      rethrow;
    }
  }
}
