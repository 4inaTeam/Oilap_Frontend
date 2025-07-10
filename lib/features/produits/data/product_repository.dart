import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/product_model.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/utils/pdf_utils.dart'; // UPDATED: Use the new unified PDF utils

// Updated TotalQuantityData Model
class TotalQuantityData {
  final double totalQuantity; // Changed to double since API returns 3630.0
  final double totalOilVolume;
  final double overallYieldPercentage;
  final Map<String, QuantityByStatus> quantityByStatus; // Changed structure
  final int totalProducts;

  TotalQuantityData({
    required this.totalQuantity,
    required this.totalOilVolume,
    required this.overallYieldPercentage,
    required this.quantityByStatus,
    required this.totalProducts,
  });

  factory TotalQuantityData.fromJson(Map<String, dynamic> json) {
    try {
      // Parse quantity_by_status with nested objects
      final quantityByStatusMap = <String, QuantityByStatus>{};
      final quantityByStatusData = json['quantity_by_status'];

      if (quantityByStatusData != null &&
          quantityByStatusData is Map<String, dynamic>) {
        quantityByStatusData.forEach((key, value) {
          if (value != null && value is Map<String, dynamic>) {
            quantityByStatusMap[key] = QuantityByStatus.fromJson(value);
          }
        });
      }

      final result = TotalQuantityData(
        totalQuantity: _parseDouble(json['total_quantity']),
        totalOilVolume: _parseDouble(json['total_oil_volume']),
        overallYieldPercentage: _parseDouble(json['overall_yield_percentage']),
        quantityByStatus: quantityByStatusMap,
        totalProducts: _parseInt(json['total_products']),
      );

      return result;
    } catch (e) {
      // Return default object on error
      return TotalQuantityData(
        totalQuantity: 0.0,
        totalOilVolume: 0.0,
        overallYieldPercentage: 0.0,
        quantityByStatus: {},
        totalProducts: 0,
      );
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Helper method to get total quantity as int for display
  int get totalQuantityInt => totalQuantity.round();

  // Backward compatibility - convert to old format for existing widgets
  Map<String, int> get quantityByStatusLegacy {
    final result = <String, int>{};
    quantityByStatus.forEach((key, value) {
      result[key] = value.totalQuantity.round();
    });
    return result;
  }

  // Legacy quantityByPayment for backward compatibility
  Map<String, int> get quantityByPayment => {};
}

class QuantityByStatus {
  final double totalQuantity;
  final double totalOil;

  QuantityByStatus({required this.totalQuantity, required this.totalOil});

  factory QuantityByStatus.fromJson(Map<String, dynamic> json) {
    try {
      return QuantityByStatus(
        totalQuantity: TotalQuantityData._parseDouble(json['total_quantity']),
        totalOil: TotalQuantityData._parseDouble(json['total_oil']),
      );
    } catch (e) {
      return QuantityByStatus(totalQuantity: 0.0, totalOil: 0.0);
    }
  }
}

// Model for Origin Percentage Response
class OriginData {
  final String origin;
  final int count;
  final double percentage;
  final int totalQuantity;
  final double quantityPercentage;

  OriginData({
    required this.origin,
    required this.count,
    required this.percentage,
    required this.totalQuantity,
    required this.quantityPercentage,
  });

  factory OriginData.fromJson(Map<String, dynamic> json) {
    return OriginData(
      origin: json['origin'] as String? ?? 'Unknown',
      count: json['count'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      totalQuantity: json['total_quantity'] as int? ?? 0,
      quantityPercentage:
          (json['quantity_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OriginPercentageData {
  final int totalProducts;
  final int totalQuantity;
  final int productsWithoutOrigin;
  final List<OriginData> originPercentages;
  final Map<String, dynamic> summary;

  OriginPercentageData({
    required this.totalProducts,
    required this.totalQuantity,
    required this.productsWithoutOrigin,
    required this.originPercentages,
    required this.summary,
  });

  factory OriginPercentageData.fromJson(Map<String, dynamic> json) {
    final originList = json['origin_percentages'] as List<dynamic>? ?? [];
    return OriginPercentageData(
      totalProducts: json['total_products'] as int? ?? 0,
      totalQuantity: json['total_quantity'] as int? ?? 0,
      productsWithoutOrigin: json['products_without_origin'] as int? ?? 0,
      originPercentages: originList.map((e) => OriginData.fromJson(e)).toList(),
      summary: Map<String, dynamic>.from(json['summary'] ?? {}),
    );
  }
}

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

  /// Get authenticated headers for HTTP requests
  Future<Map<String, String>> _getAuthHeaders({
    Map<String, String>? additionalHeaders,
  }) async {
    final token = await authRepo.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception(
        'Authentication token not available. Please log in again.',
      );
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?additionalHeaders,
    };

    return headers;
  }

  Future<ProductPaginationResult> fetchProducts({
    int page = 1,
    int pageSize = 10,
    String? searchQuery,
  }) async {
    try {
      final headers = await _getAuthHeaders();

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

      final resp = await http.get(uri, headers: headers);

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
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error fetching products: ${e.toString()}');
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
    try {
      final headers = await _getAuthHeaders();

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
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (resp.statusCode != 201 && resp.statusCode != 200) {
        throw Exception('Create failed: ${resp.body}');
      }
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error creating product: ${e.toString()}');
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
    try {
      final headers = await _getAuthHeaders();

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
        headers: headers,
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
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error updating product: ${e.toString()}');
    }
  }

  Future<void> updateProductStatus(int productId, String newStatus) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/api/products/$productId/update/'),
        headers: headers,
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode != 200) {
        throw Exception('Status update failed: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error updating product status: ${e.toString()}');
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final headers = await _getAuthHeaders();

      final resp = await http.delete(
        Uri.parse('$baseUrl/api/products/delete/$productId/'),
        headers: headers,
      );

      if (resp.statusCode != 204) {
        throw Exception('Delete failed: ${resp.body}');
      }
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error deleting product: ${e.toString()}');
    }
  }

  Future<void> cancelProduct(dynamic product) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.patch(
        Uri.parse('$baseUrl/api/products/${product.id}/cancel/'),
        headers: headers,
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
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Cancel failed: ${e.toString()}');
    }
  }

  // UPDATED: Fixed cross-platform PDF download using new unified PDF utils
  Future<String> downloadProductPDF(int productId) async {
    try {
      final headers = await _getAuthHeaders(
        additionalHeaders: {'Accept': 'application/pdf'},
      );

      // Method 1: Try to fetch PDF bytes first
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/$productId/pdf/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final fileName = 'produit_$productId.pdf';

        // Use the unified PDF utils to download
        final result = await PdfUtils.downloadPdfFromBytes(
          bytes: response.bodyBytes,
          fileName: fileName,
        );

        return result;
      } else if (response.statusCode == 406) {
        throw Exception(
          'Server rejected the request (406). Check Django view accepts the request format.',
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        throw Exception('Download failed with status ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error downloading PDF: ${e.toString()}');
    }
  }

  // Alternative method: Download PDF from URL
  Future<String> downloadProductPDFFromUrl(int productId) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) {
        throw Exception(
          'Authentication token not available. Please log in again.',
        );
      }

      final fileName = 'produit_$productId.pdf';
      final url = '$baseUrl/api/products/$productId/pdf/';

      // Use the unified PDF utils to download from URL
      final result = await PdfUtils.downloadPdfFromUrl(
        url: url,
        fileName: fileName,
        headers: {'Authorization': 'Bearer $token'},
      );

      return result;
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error downloading PDF from URL: ${e.toString()}');
    }
  }

  Future<TotalQuantityData> fetchTotalQuantity() async {
    try {
      final headers = await _getAuthHeaders();

      final resp = await http.get(
        Uri.parse('$baseUrl/api/products/total-quantity/'),
        headers: headers,
      );

      if (resp.statusCode == 200) {
        final responseData = json.decode(resp.body);
        final quantityData = TotalQuantityData.fromJson(responseData);
        return quantityData;
      } else if (resp.statusCode == 404) {
        // Return default data for 404
        return TotalQuantityData(
          totalQuantity: 0.0,
          totalOilVolume: 0.0,
          overallYieldPercentage: 0.0,
          quantityByStatus: {},
          totalProducts: 0,
        );
      } else {
        throw Exception(
          'Failed to fetch total quantity: ${resp.statusCode} - ${resp.body}',
        );
      }
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error fetching total quantity: ${e.toString()}');
    }
  }

  Future<OriginPercentageData> fetchOriginPercentages() async {
    try {
      final headers = await _getAuthHeaders();

      final resp = await http.get(
        Uri.parse('$baseUrl/api/products/origin-percentages/'),
        headers: headers,
      );

      if (resp.statusCode == 200) {
        final responseData = json.decode(resp.body);
        return OriginPercentageData.fromJson(responseData);
      }

      throw Exception('Failed to fetch origin percentages: ${resp.statusCode}');
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error fetching origin percentages: ${e.toString()}');
    }
  }
}
