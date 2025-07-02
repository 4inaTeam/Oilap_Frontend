import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/models/product_model.dart';
import '../../auth/data/auth_repository.dart';

// Fixed conditional imports with proper aliases
import '../../../core/utils/web_utils_stub.dart'
    if (dart.library.html) '../../../core/utils/web_utils_web.dart'
    as web_utils;
import '../../../core/utils/mobile_utils.dart'
    if (dart.library.html) '../../../core/utils/web_utils_stub.dart'
    as mobile_utils;

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
    int pageSize = 10,
    String? searchQuery,
  }) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        'ordering': '-created_at',
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final statusQuery = searchQuery.toLowerCase();
        if (['pending', 'doing', 'done'].contains(statusQuery)) {
          queryParams['status'] = statusQuery;
        } else if (searchQuery.contains('/')) {
          queryParams['end_time'] = searchQuery;
        } else {
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

        if (responseData is Map && responseData.containsKey('results')) {
          data = responseData['results'] as List<dynamic>;
          totalCount = responseData['count'] as int? ?? 0;
        } else {
          final allData = responseData as List<dynamic>;
          allData.sort((a, b) {
            final dateA =
                DateTime.tryParse(a['created_at']?.toString() ?? '') ??
                DateTime(1970);
            final dateB =
                DateTime.tryParse(b['created_at']?.toString() ?? '') ??
                DateTime(1970);
            return dateB.compareTo(dateA);
          });
          totalCount = allData.length;
          final startIndex = (page - 1) * pageSize;
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

    if (status == 'doing') {
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

  Future<void> cancelProduct(dynamic product) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.patch(
        Uri.parse('$baseUrl/api/products/${product.id}/cancel/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': 'canceled',
          'price': product.price.toString(),
          'client': product.client,
          'quantity': product.quantity,
          'quality': product.quality,
          'origine': product.origine,
          'estimation_time': 30,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to cancel product');
      }
    } catch (e) {
      throw Exception('Cancel failed: ${e.toString()}');
    }
  }

  // Fixed cross-platform PDF download
  Future<String> downloadProductPDF(int productId) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/api/products/$productId/pdf/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final fileName = 'produit_$productId.pdf';

        if (kIsWeb) {
          // Web platform - browser download
          web_utils.downloadPdfWeb(response.bodyBytes, fileName);
          return 'PDF downloaded successfully';
        } else {
          // Mobile/Desktop platform - save to device
          await mobile_utils.downloadPdfMobile(response.bodyBytes, fileName);
          return 'PDF saved to Downloads folder';
        }
      } else if (response.statusCode == 406) {
        throw Exception(
          'Server rejected the request (406). Check Django view accepts the request format.',
        );
      } else {
        throw Exception('Download failed with status ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
