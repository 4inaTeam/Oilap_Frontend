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

      // Build query parameters
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final statusQuery = searchQuery.toLowerCase();
        if (['pending', 'doing', 'done'].contains(statusQuery)) {
          queryParams['status'] = statusQuery;
        } else if (searchQuery.contains('/')) {
          // If query contains /, treat as date search
          queryParams['end_time'] = searchQuery;
        } else {
          // Default to client search
          queryParams['client'] = searchQuery;
        }
      }

      final uri = Uri.parse(
        '$baseUrl/api/products/',
      ).replace(queryParameters: queryParams);

      final resp = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        final responseData = json.decode(resp.body);
        List<dynamic> data;
        int totalCount;

        // Handle paginated response
        if (responseData is Map && responseData.containsKey('results')) {
          data = responseData['results'] as List<dynamic>;
          totalCount = responseData['count'] as int? ?? 0;
        } else {
          // Handle non-paginated response with manual pagination
          final allData = responseData as List<dynamic>;
          totalCount = allData.length;

          // Calculate start and end indices for current page
          final startIndex = (page - 1) * pageSize;

          // Get slice of data for current page
          data = allData.skip(startIndex).take(pageSize).toList();
        }

        final products =
            data.map((item) {
              final productJson = Map<String, dynamic>.from(item);
              if (productJson['client_details'] == null &&
                  productJson['client'] != null) {
                productJson['client_details'] = {
                  'cin': productJson['client'],
                  'username':
                      productJson['client_name'] ??
                      'Client ${productJson['client']}',
                };
              }
              return Product.fromJson(productJson);
            }).toList();

        return ProductPaginationResult(
          products: products,
          totalCount: totalCount,
          currentPage: page,
          totalPages: (totalCount / pageSize).ceil(),
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
    required double quantity,
    required String clientCin,
    required int estimationTime,
    String? status,
    DateTime? end_time,
  }) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final requestBody = {
      'quality': quality,
      'origine': origine,
      'price': price,
      'quantity': quantity,
      'client': clientCin,
      'estimation_time': estimationTime,
      if (status != null) 'status': status,
      if (end_time != null) 'end_time': end_time.toIso8601String(),
    };

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
    String? quality,
    String? origine,
    double? price,
    double? quantity,
    String? clientCin,
    int? estimationTime,
    String? status,
    DateTime? end_time,
  }) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final Map<String, dynamic> body = {};

    // Get current product status first
    final currentStatus = status;

    // If status is 'doing', only allow status update
    if (currentStatus == 'doing') {
      if (status != null) body['status'] = status;
    } else {

      if (quality != null) body['quality'] = quality;
      if (origine != null) body['origine'] = origine;
      if (price != null) body['price'] = price;
      if (quantity != null) body['quantity'] = quantity;
      if (clientCin != null) body['client'] = clientCin;
      if (estimationTime != null) body['estimation_time'] = estimationTime;
      if (status != null) body['status'] = status;
      if (end_time != null) body['end_time'] = end_time.toIso8601String();
    }

    final resp = await http.patch(
      Uri.parse('$baseUrl/api/products/$id/update/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      final errorData = json.decode(resp.body);
      if (errorData is Map && errorData.containsKey('detail')) {
        throw Exception(errorData['detail'].toString());
      } else {
        throw Exception(errorData.toString());
      }
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
