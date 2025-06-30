import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/bill_model.dart';
import '../../auth/data/auth_repository.dart';

class BillPaginationResult {
  final List<Bill> bills;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  BillPaginationResult({
    required this.bills,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });
}

class BillRepository {
  final String baseUrl;
  final AuthRepository authRepo;

  BillRepository({required this.baseUrl, required this.authRepo});

  Bill _safeBillFromJson(Map<String, dynamic> json, {int? index}) {
    try {
      return Bill.fromJson(json);
    } catch (e) {
      return Bill(
        id:
            json['id'] is String
                ? int.tryParse(json['id']) ?? 0
                : (json['id'] as int?) ?? 0,
        owner: json['owner']?.toString() ?? 'Unknown',
        amount: _parseDouble(json['amount']),
        category: json['category']?.toString() ?? 'purchase',
        paymentDate:
            json['payment_date'] != null
                ? DateTime.tryParse(json['payment_date'].toString()) ??
                    DateTime.now()
                : DateTime.now(),
        consumption:
            json['consumption'] != null
                ? _parseDouble(json['consumption'])
                : null,
        pdfFile: json['pdf_file']?.toString(),
        originalImage: json['original_image']?.toString(),
        items: json['items'] != null ? _parseItems(json['items']) : null,
        createdAt:
            json['created_at'] != null
                ? DateTime.tryParse(json['created_at'].toString())
                : DateTime.now(),
      );
    }
  }

  /// Parse items from JSON
  List<Map<String, dynamic>>? _parseItems(dynamic itemsData) {
    try {
      if (itemsData == null) return null;
      if (itemsData is String) {
        final decoded = jsonDecode(itemsData);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      }
      if (itemsData is List) {
        return itemsData.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Helper function matching the Bill model's _parseDouble
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String cleanValue = value.replaceAll(',', '.').trim();
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  /// Fetch PDF as bytes from the server
  Future<Uint8List?> fetchBillPdfBytes(String pdfUrl) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      // Handle URL encoding properly
      String fullUrl = pdfUrl;
      if (!pdfUrl.startsWith('http')) {
        fullUrl = '$baseUrl$pdfUrl';
      }

      // Decode URL to handle special characters
      final uri = Uri.parse(fullUrl);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }

      throw Exception('Failed to fetch PDF: ${response.statusCode}');
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> convertPdfToImageBytes(Uint8List pdfBytes) async {
    try {
      final imagesStream = Printing.raster(pdfBytes, pages: [0], dpi: 200);

      final images = <PdfRaster>[];
      await for (final page in imagesStream) {
        images.add(page);
      }

      if (images.isNotEmpty) {
        return await images.first.toPng();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> fetchBillPdfAsImage(String pdfUrl) async {
    try {
      final pdfBytes = await fetchBillPdfBytes(pdfUrl);
      if (pdfBytes == null) return null;

      return await convertPdfToImageBytes(pdfBytes);
    } catch (e) {
      return null;
    }
  }

  String? getBillPdfUrl(Bill bill) {
    if (bill.pdfFile == null || bill.pdfFile!.isEmpty) return null;

    if (bill.pdfFile!.startsWith('http')) {
      return bill.pdfFile;
    }

    return '$baseUrl${bill.pdfFile}';
  }

  String? getBillOriginalImageUrl(Bill bill) {
    if (bill.originalImage == null || bill.originalImage!.isEmpty) return null;

    // If the URL is already absolute, return it
    if (bill.originalImage!.startsWith('http')) {
      return bill.originalImage;
    }

    // If it's relative, make it absolute
    return '$baseUrl${bill.originalImage}';
  }

  /// Fetch bills with pagination, search, and filtering
  Future<BillPaginationResult> fetchBills({
    int page = 1,
    int pageSize = 6,
    String? searchQuery,
    String? categoryFilter,
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

      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        queryParams['category'] = categoryFilter;
      }

      queryParams['ordering'] = '-created_at';

      final uri = Uri.parse(
        '$baseUrl/api/bills/list/',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> billsData;
        int totalCount;

        if (responseData is Map && responseData.containsKey('results')) {
          // Paginated response
          billsData = responseData['results'] as List<dynamic>;
          totalCount = responseData['count'] as int;
        } else {
          // Non-paginated response - handle client-side pagination
          final allBillsJson = (responseData as List<dynamic>);

          // Parse all bills first
          var allBills = <Bill>[];
          for (int i = 0; i < allBillsJson.length; i++) {
            allBills.add(_safeBillFromJson(allBillsJson[i], index: i));
          }

          // Apply client-side filtering
          var filteredBills = allBills;

          if (searchQuery != null && searchQuery.isNotEmpty) {
            filteredBills =
                filteredBills
                    .where(
                      (bill) =>
                          bill.owner.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ) ||
                          bill.category.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();
          }

          if (categoryFilter != null && categoryFilter.isNotEmpty) {
            filteredBills =
                filteredBills
                    .where((bill) => bill.category == categoryFilter)
                    .toList();
          }

          totalCount = filteredBills.length;
          final startIndex = (page - 1) * pageSize;

          // Return the filtered and paginated bills directly
          final paginatedBills =
              filteredBills.skip(startIndex).take(pageSize).toList();

          return BillPaginationResult(
            bills: paginatedBills,
            totalCount: totalCount,
            currentPage: page,
            totalPages: (totalCount / pageSize).ceil(),
          );
        }

        // Parse bills with safe parsing
        final bills = <Bill>[];
        for (int i = 0; i < billsData.length; i++) {
          bills.add(_safeBillFromJson(billsData[i], index: i));
        }

        final totalPages = (totalCount / pageSize).ceil();

        return BillPaginationResult(
          bills: bills,
          totalCount: totalCount,
          currentPage: page,
          totalPages: totalPages,
        );
      }

      throw Exception(
        'Failed to fetch bills: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Error fetching bills: ${e.toString()}');
    }
  }

  /// Fetch all bills without pagination
  Future<List<Bill>> fetchAllBills() async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/api/bills/list/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> billsData;
        if (responseData is Map && responseData.containsKey('results')) {
          billsData = responseData['results'] as List<dynamic>;
        } else {
          billsData = responseData as List<dynamic>;
        }

        final bills = <Bill>[];
        for (int i = 0; i < billsData.length; i++) {
          bills.add(_safeBillFromJson(billsData[i], index: i));
        }

        return bills;
      }

      throw Exception('Failed to fetch all bills: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching all bills: ${e.toString()}');
    }
  }

  /// Fetch a specific bill by ID
  Future<Bill> fetchBillById(int id) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/api/bills/$id/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _safeBillFromJson(data);
      }

      throw Exception('Failed to fetch bill: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching bill: ${e.toString()}');
    }
  }

  // Updated createBill method that handles both mobile and web
  // Updated createBill method that handles the new Item model structure
  Future<Bill> createBill({
    required String owner,
    required String category,
    required double amount,
    required DateTime paymentDate,
    double? consumption,
    List<Map<String, dynamic>>? items,
    File? imageFile,
    Uint8List? webImageBytes,
  }) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      // Validate that we have either an image file or web image bytes
      if (imageFile == null && webImageBytes == null) {
        throw Exception(
          'No image provided - image is required for bill creation',
        );
      }

      if (kIsWeb) {
        // Web implementation using multipart form data
        return _createBillForWeb(
          owner: owner,
          category: category,
          amount: amount,
          paymentDate: paymentDate,
          consumption: consumption,
          items: items,
          webImageBytes: webImageBytes,
          token: token,
        );
      } else {
        // Mobile/Desktop implementation using MultipartRequest
        return _createBillForMobile(
          owner: owner,
          category: category,
          amount: amount,
          paymentDate: paymentDate,
          consumption: consumption,
          items: items,
          imageFile: imageFile,
          token: token,
        );
      }
    } catch (e) {
      throw Exception('Error creating bill: ${e.toString()}');
    }
  }

  // Fixed Web implementation - ensure image is properly added
  Future<Bill> _createBillForWeb({
    required String owner,
    required String category,
    required double amount,
    required DateTime paymentDate,
    double? consumption,
    List<Map<String, dynamic>>? items,
    Uint8List? webImageBytes,
    required String token,
  }) async {
    if (webImageBytes == null) {
      throw Exception('No image provided for web');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/bills/'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // Add basic form fields
    request.fields['owner'] = owner;
    request.fields['category'] = category;
    request.fields['amount'] = amount.toString();
    request.fields['payment_date'] =
        paymentDate.toIso8601String().split('T')[0];

    if (consumption != null) {
      request.fields['consumption'] = consumption.toString();
    }

    // Handle items for purchase bills - Django expects nested form data
    if (category == 'purchase' && items != null && items.isNotEmpty) {
      // Send items count first (some Django setups need this)
      request.fields['items-TOTAL_FORMS'] = items.length.toString();
      request.fields['items-INITIAL_FORMS'] = '0';
      request.fields['items-MIN_NUM_FORMS'] = '0';
      request.fields['items-MAX_NUM_FORMS'] = '1000';

      // Send each item as nested form data
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        // Django formset format
        request.fields['items-$i-title'] = item['name']?.toString() ?? '';
        request.fields['items-$i-quantity'] =
            item['quantity']?.toString() ?? '0';
        request.fields['items-$i-unit_price'] =
            item['price']?.toString() ?? '0';
      }
    }

    try {
      final multipartFile = http.MultipartFile.fromBytes(
        'original_image',
        webImageBytes,
        filename: 'bill_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);
    } catch (e) {
      throw Exception('Failed to add image to request: ${e.toString()}');
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        return _safeBillFromJson(data);
      }

      // Parse and throw specific error
      String errorMessage = 'Failed to create bill';
      try {
        final errorData = json.decode(responseBody);
        if (errorData is Map<String, dynamic>) {
          final errors = <String>[];
          errorData.forEach((key, value) {
            if (value is List) {
              errors.addAll(value.cast<String>());
            } else if (value is String) {
              errors.add('$key: $value');
            }
          });
          if (errors.isNotEmpty) {
            errorMessage = errors.join(', ');
          }
        }
      } catch (e) {
        errorMessage = responseBody;
      }

      throw Exception('$errorMessage (Status: ${response.statusCode})');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Bill> _createBillForMobile({
    required String owner,
    required String category,
    required double amount,
    required DateTime paymentDate,
    double? consumption,
    List<Map<String, dynamic>>? items,
    File? imageFile,
    required String token,
  }) async {
    if (imageFile == null) {
      throw Exception('No image file provided for mobile');
    }

    if (!await imageFile.exists()) {
      throw Exception('Image file does not exist');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/bills/'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // Add basic form fields
    request.fields['owner'] = owner;
    request.fields['category'] = category;
    request.fields['amount'] = amount.toString();
    request.fields['payment_date'] =
        paymentDate.toIso8601String().split('T')[0];

    if (consumption != null) {
      request.fields['consumption'] = consumption.toString();
    }

    if (category == 'purchase' && items != null && items.isNotEmpty) {
      request.fields['items-TOTAL_FORMS'] = items.length.toString();
      request.fields['items-INITIAL_FORMS'] = '0';
      request.fields['items-MIN_NUM_FORMS'] = '0';
      request.fields['items-MAX_NUM_FORMS'] = '1000';

      for (int i = 0; i < items.length; i++) {
        final item = items[i];

        request.fields['items-$i-title'] = item['name']?.toString() ?? '';
        request.fields['items-$i-quantity'] =
            item['quantity']?.toString() ?? '0';
        request.fields['items-$i-unit_price'] =
            item['price']?.toString() ?? '0';
      }
    }

    try {
      final multipartFile = await http.MultipartFile.fromPath(
        'original_image',
        imageFile.path,
      );
      request.files.add(multipartFile);
    } catch (e) {
      throw Exception('Failed to add image file to request: ${e.toString()}');
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        return _safeBillFromJson(data);
      }

      // Parse and throw specific error
      String errorMessage = 'Failed to create bill';
      try {
        final errorData = json.decode(responseBody);
        if (errorData is Map<String, dynamic>) {
          final errors = <String>[];
          errorData.forEach((key, value) {
            if (value is List) {
              errors.addAll(value.cast<String>());
            } else if (value is String) {
              errors.add('$key: $value');
            }
          });
          if (errors.isNotEmpty) {
            errorMessage = errors.join(', ');
          }
        }
      } catch (e) {
        errorMessage = responseBody;
      }

      throw Exception('$errorMessage (Status: ${response.statusCode})');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Bill> updateBill({
    required int id,
    required String owner,
    required String category,
    required double amount,
    required DateTime paymentDate,
    double? consumption,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      // Transform items to match backend expectations
      List<Map<String, dynamic>>? transformedItems;
      if (items != null) {
        transformedItems =
            items.map((item) {
              return {
                'title': item['name']?.toString() ?? '',
                'quantity': item['quantity'],
                'unit_price': item['price'],
              };
            }).toList();
      }

      final requestBody = {
        'owner': owner,
        'category': category,
        'amount': amount,
        'payment_date': paymentDate.toIso8601String().split('T')[0],
        if (consumption != null) 'consumption': consumption,
        if (transformedItems != null) 'items': transformedItems,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/api/bills/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _safeBillFromJson(data);
      }

      if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        final errors = <String>[];

        if (errorData is Map<String, dynamic>) {
          errorData.forEach((key, value) {
            if (value is List) {
              errors.addAll(value.cast<String>());
            } else if (value is String) {
              errors.add('$key: $value');
            }
          });
        }

        throw Exception(
          errors.isNotEmpty ? errors.join(', ') : 'Validation failed',
        );
      }

      throw Exception('Failed to update bill: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error updating bill: ${e.toString()}');
    }
  }

  Future<void> deleteBill(int billId) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse('$baseUrl/api/bills/$billId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete bill: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting bill: ${e.toString()}');
    }
  }

  Future<List<Bill>> fetchBillsByCategory(String category) async {
    final result = await fetchBills(categoryFilter: category);
    return result.bills;
  }

  Future<bool> downloadBillPdf(Bill bill, String savePath) async {
    try {
      final pdfUrl = getBillPdfUrl(bill);
      if (pdfUrl == null) return false;

      final pdfBytes = await fetchBillPdfBytes(pdfUrl);
      if (pdfBytes == null) return false;

      final file = File(savePath);
      await file.writeAsBytes(pdfBytes);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> printBillPdf(Bill bill) async {
    try {
      final pdfUrl = getBillPdfUrl(bill);
      if (pdfUrl == null) throw Exception('No PDF available');

      final pdfBytes = await fetchBillPdfBytes(pdfUrl);
      if (pdfBytes == null) throw Exception('Failed to fetch PDF');

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      throw Exception('Error printing PDF: ${e.toString()}');
    }
  }

  String? getBillImageUrl(Bill bill) {
    if (bill.originalImage == null || bill.originalImage!.isEmpty) {
      return null;
    }

    if (bill.originalImage!.startsWith('http')) {
      return bill.originalImage;
    }

    String imageUrl = bill.originalImage!;

    if (!imageUrl.startsWith('/')) {
      imageUrl = '/$imageUrl';
    }

    return '$baseUrl$imageUrl';
  }

  Future<Uint8List?> fetchBillImageBytes(String imageUrl) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      String fullUrl = imageUrl;
      if (!imageUrl.startsWith('http')) {
        fullUrl = '$baseUrl$imageUrl';
      }

      final uri = Uri.parse(fullUrl);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token', 'Accept': 'image/*'},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }

      throw Exception('Failed to fetch image: ${response.statusCode}');
    } catch (e) {
      return null;
    }
  }
}
