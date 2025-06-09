import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/facture_model.dart';
import '../../auth/data/auth_repository.dart';

class FactureRepository {
  final String baseUrl;
  final AuthRepository authRepo;

  FactureRepository({required this.baseUrl, required this.authRepo});

  Future<List<Facture>> fetchFactures() async {
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
      throw Exception('Failed to fetch factures: ${e.toString()}');
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
        return Facture.fromJson(json.decode(resp.body));
      }
      throw Exception('Failed to fetch facture details');
    } catch (e) {
      throw Exception('Error getting facture details: ${e.toString()}');
    }
  }

  // Add this method to get PDF URL for a specific facture
  Future<String> getFacturePdfUrl(int factureId) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.get(
        Uri.parse('$baseUrl/api/factures/$factureId/view_pdf/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        return data['pdf_url'] as String;
      }
      throw Exception('Failed to get PDF URL: ${resp.statusCode}');
    } catch (e) {
      throw Exception('Error getting PDF URL: ${e.toString()}');
    }
  }

  // Add this method to download PDF
  Future<String> downloadFacturePdf(int factureId) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final resp = await http.get(
        Uri.parse('$baseUrl/api/factures/$factureId/download_pdf/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 302 || resp.statusCode == 200) {
        // If it's a redirect, return the location header
        if (resp.headers.containsKey('location')) {
          return resp.headers['location']!;
        }
        // If it's direct content, you might need to handle this differently
        // For now, we'll assume it returns a URL in JSON
        final data = json.decode(resp.body);
        return data['pdf_url'] as String;
      }
      throw Exception('Failed to download PDF: ${resp.statusCode}');
    } catch (e) {
      throw Exception('Error downloading PDF: ${e.toString()}');
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

  Future<void> updateFactureStatus(
    int factureId,
    String newStatus, {
    DateTime? paymentDate,
  }) async {
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

  // Helper method to get PDF URL from facture model
  String getPdfUrl(Facture facture) => facture.pdfUrl;
}