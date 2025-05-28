import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/product_model.dart';
import '../../auth/data/auth_repository.dart';

class ProductPaginationResult {
  final List<Product> products;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  ProductPaginationResult({
    required this.products,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });
}

class ProductRepository {
  final String baseUrl;
  final AuthRepository authRepo;

  ProductRepository({required this.baseUrl, required this.authRepo});

  Future<ProductPaginationResult> fetchProducts({
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
        queryParams['search'] = searchQuery;
      }

      final uri = Uri.parse(
        '$baseUrl/api/products/',
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
          // Paginated response
          data = responseData['results'] as List<dynamic>;
          totalCount = responseData['count'] as int? ?? data.length;
        } else {
          // Non-paginated response - handle client-side pagination
          final allData = responseData as List<dynamic>;
          final allProducts = allData
              .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          // Apply search filter if provided
          if (searchQuery != null && searchQuery.isNotEmpty) {
            allProducts.removeWhere((product) =>
                !product.quality.toLowerCase().contains(searchQuery.toLowerCase()) &&
                !product.origine.toLowerCase().contains(searchQuery.toLowerCase()) &&
                !product.status.toLowerCase().contains(searchQuery.toLowerCase()) &&
                !product.clientCin.toLowerCase().contains(searchQuery.toLowerCase()));
          }

          totalCount = allProducts.length;
          final startIndex = (page - 1) * pageSize;

          data = allProducts
              .skip(startIndex)
              .take(pageSize)
              .map((product) => product.toJson())
              .toList();
        }

        final products = data
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        final totalPages = (totalCount / pageSize).ceil();

        return ProductPaginationResult(
          products: products,
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

  Future<List<Product>> fetchAllProducts() async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.get(
        Uri.parse('$baseUrl/api/products/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        return data
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createProduct({
    required String quality,
    required String origine,
    required double price,
    required String status,
    required String clientCin,
    int? clientId,
  }) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final Map<String, dynamic> requestBody = {
      'quality': quality,
      'origine': origine,
      'price': price,
      'status': status,
      'client_Cin': clientCin,
    };

    if (clientId != null) {
      requestBody['client_id'] = clientId;
    }

    final resp = await http.post(
      Uri.parse('$baseUrl/api/products/create/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Create failed: ${resp.body}');
    }
  }

  Future<void> updateProduct({
    required int id,
    required String quality,
    required String origine,
    required double price,
    required String status,
    required String clientCin,
    int? clientId,
  }) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final Map<String, dynamic> requestBody = {
      'quality': quality,
      'origine': origine,
      'price': price,
      'status': status,
      'client_Cin': clientCin,
    };

    if (clientId != null) {
      requestBody['client_id'] = clientId;
    }

    final resp = await http.patch(
      Uri.parse('$baseUrl/api/products/$id/update/'),
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

  Future<void> updateProductStatus(int productId, String newStatus) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.put(
      Uri.parse('$baseUrl/api/products/$productId/update/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': newStatus}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Status update failed: ${response.body}');
    }
  }

  Future<void> deleteProduct(int productId) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final resp = await http.delete(
      Uri.parse('$baseUrl/api/products/delete/$productId/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode != 204) {
      throw Exception('Delete failed: ${resp.body}');
    }
  }

  // Additional method to fetch products by client
  Future<List<Product>> fetchProductsByClient(int clientId) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.get(
        Uri.parse('$baseUrl/api/products/client/$clientId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        return data
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}