import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/facture_model.dart';
import '../../auth/data/auth_repository.dart';

class FacturePaginationResult {
  final List<Facture> factures;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  FacturePaginationResult({
    required this.factures,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });
}

class FactureRepository {
  final String baseUrl;
  final AuthRepository authRepo;

  FactureRepository({required this.baseUrl, required this.authRepo});

  Future<FacturePaginationResult> fetchFactures({
    int page = 1,
    int pageSize = 10,
    String? searchQuery,
    String? statusFilter,
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

      if (statusFilter != null && statusFilter.isNotEmpty) {
        queryParams['status'] = statusFilter;
      }

      final uri = Uri.parse(
        '$baseUrl/api/factures/',
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

          List<dynamic> filteredData = allData;
          if (searchQuery != null && searchQuery.isNotEmpty) {
            filteredData = allData.where((item) {
              final facture = Facture.fromJson(item);
              return facture.id.toString().contains(searchQuery.toLowerCase()) ||
                  facture.client.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  facture.totalAmount.contains(searchQuery) ||
                  facture.status.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();
          }

          if (statusFilter != null && statusFilter.isNotEmpty) {
            filteredData = filteredData.where((item) {
              final facture = Facture.fromJson(item);
              return facture.status.toLowerCase() == statusFilter.toLowerCase();
            }).toList();
          }

          totalCount = filteredData.length;
          final startIndex = (page - 1) * pageSize;
          data = filteredData.skip(startIndex).take(pageSize).toList();
        }

        final factures = data.map((e) => Facture.fromJson(e)).toList();
        final totalPages = (totalCount / pageSize).ceil();

        return FacturePaginationResult(
          factures: factures,
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

  Future<List<Facture>> fetchAllFactures() async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.get(
        Uri.parse('$baseUrl/api/factures/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        return data.map((e) => Facture.fromJson(e)).toList();
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Facture>> searchFactures(String query) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.get(
        Uri.parse('$baseUrl/api/factures/search/?q=$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        return data.map((e) => Facture.fromJson(e)).toList();
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Facture>> getFacturesByStatus(String status) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.get(
        Uri.parse('$baseUrl/api/factures/filter/?status=$status'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        return data.map((e) => Facture.fromJson(e)).toList();
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Facture> getFactureDetail(int factureId) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.get(
        Uri.parse('$baseUrl/api/factures/$factureId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(resp.body);
        return Facture.fromJson(data);
      }
      throw Exception('Failed with status ${resp.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createFacture({
    required String type,
    required int productId,
    required String client,
    required int employeeId,
    required int accountantId,
    required String baseAmount,
    required String taxAmount,
    required String totalAmount,
    required DateTime issueDate,
    required DateTime dueDate,
    String status = 'unpaid',
  }) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final resp = await http.post(
      Uri.parse('$baseUrl/api/factures/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'product': productId,
        'client': client,
        'employee': employeeId,
        'accountant': accountantId,
        'base_amount': baseAmount,
        'tax_amount': taxAmount,
        'total_amount': totalAmount,
        'issue_date': issueDate.toIso8601String().split('T')[0],
        'due_date': dueDate.toIso8601String().split('T')[0],
        'status': status,
      }),
    );

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Create failed: ${resp.body}');
    }
  }

  Future<void> updateFacture({
    required int id,
    required String type,
    required int productId,
    required String client,
    required int employeeId,
    required int accountantId,
    required String baseAmount,
    required String taxAmount,
    required String totalAmount,
    required DateTime issueDate,
    required DateTime dueDate,
    required String status,
    DateTime? paymentDate,
  }) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final Map<String, dynamic> requestBody = {
      'type': type,
      'product': productId,
      'client': client,
      'employee': employeeId,
      'accountant': accountantId,
      'base_amount': baseAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'issue_date': issueDate.toIso8601String().split('T')[0],
      'due_date': dueDate.toIso8601String().split('T')[0],
      'status': status,
    };

    if (paymentDate != null) {
      requestBody['payment_date'] = paymentDate.toIso8601String().split('T')[0];
    }

    final resp = await http.patch(
      Uri.parse('$baseUrl/api/factures/$id/'),
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
        errorMessage = 'Update failed: $responseBody';
      }

      throw Exception(errorMessage);
    }
  }

  Future<void> updateFactureStatus(int factureId, String newStatus, {DateTime? paymentDate}) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final Map<String, dynamic> requestBody = {'status': newStatus};
    
    if (paymentDate != null) {
      requestBody['payment_date'] = paymentDate.toIso8601String().split('T')[0];
    }

    final resp = await http.patch(
      Uri.parse('$baseUrl/api/factures/$factureId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (resp.statusCode != 200) {
      throw Exception('Status update failed: ${resp.body}');
    }
  }

  Future<void> deleteFacture(int factureId) async {
    final token = await authRepo.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final resp = await http.delete(
      Uri.parse('$baseUrl/api/factures/$factureId/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Delete failed: ${resp.body}');
    }
  }
}