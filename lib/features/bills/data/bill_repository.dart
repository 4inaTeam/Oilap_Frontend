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

  /// Get authenticated headers for multipart requests
  Future<Map<String, String>> _getMultipartAuthHeaders() async {
    final token = await authRepo.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception(
        'Authentication token not available. Please log in again.',
      );
    }

    return {
      'Authorization': 'Bearer $token',
      // Don't set Content-Type for multipart requests - let http package handle it
    };
  }

  /// Handle HTTP response errors with better error messages
  void _handleHttpError(http.Response response, String operation) {
    switch (response.statusCode) {
      case 401:
        throw Exception('Authentication failed. Please log in again.');
      case 403:
        throw Exception('You do not have permission to perform this action.');
      case 404:
        throw Exception('Resource not found.');
      case 422:
        throw Exception('Invalid data provided.');
      case 500:
        throw Exception('Server error. Please try again later.');
      default:
        try {
          final errorData = json.decode(response.body);
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
              throw Exception(errors.join(', '));
            }
          }
        } catch (e) {
          // If we can't parse the error, use a generic message
        }
        throw Exception(
          '$operation failed: ${response.statusCode} - ${response.body}',
        );
    }
  }

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

  /// FIXED: Fetch PDF as bytes from the server with better error handling
  Future<Uint8List?> fetchBillPdfBytes(String pdfUrl) async {
    try {
      final headers = await _getAuthHeaders(
        additionalHeaders: {
          'Accept': 'application/pdf',
          'Content-Type':
              'application/pdf', // Remove this line, it's not needed for GET
        },
      );

      // Handle URL encoding properly
      String fullUrl = pdfUrl;
      if (!pdfUrl.startsWith('http')) {
        fullUrl = '$baseUrl$pdfUrl';
      }

      print('Fetching PDF from: $fullUrl'); // Debug log

      final uri = Uri.parse(fullUrl);
      final response = await http.get(uri, headers: headers);

      print('PDF fetch response: ${response.statusCode}'); // Debug log

      if (response.statusCode == 200) {
        // Verify we got a PDF
        final contentType = response.headers['content-type'];
        if (contentType != null && !contentType.contains('application/pdf')) {
          throw Exception('Response is not a PDF. Content-Type: $contentType');
        }
        return response.bodyBytes;
      }

      _handleHttpError(response, 'PDF fetch');
      return null;
    } catch (e) {
      print('Error fetching PDF: $e'); // Debug log
      if (e.toString().contains('Authentication')) {
        rethrow; // Re-throw auth errors
      }
      return null;
    }
  }

  /// FIXED: Fetch image bytes with better authentication
  Future<Uint8List?> fetchBillImageBytes(String imageUrl) async {
    try {
      final headers = await _getAuthHeaders(
        additionalHeaders: {'Accept': 'image/*'},
      );

      String fullUrl = imageUrl;
      if (!imageUrl.startsWith('http')) {
        fullUrl = '$baseUrl$imageUrl';
      }

      print('Fetching image from: $fullUrl'); // Debug log

      final uri = Uri.parse(fullUrl);
      final response = await http.get(uri, headers: headers);

      print('Image fetch response: ${response.statusCode}'); // Debug log

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }

      _handleHttpError(response, 'Image fetch');
      return null;
    } catch (e) {
      print('Error fetching image: $e'); // Debug log
      if (e.toString().contains('Authentication')) {
        rethrow; // Re-throw auth errors
      }
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
      print('Error converting PDF to image: $e');
      return null;
    }
  }

  Future<Uint8List?> fetchBillPdfAsImage(String pdfUrl) async {
    try {
      final pdfBytes = await fetchBillPdfBytes(pdfUrl);
      if (pdfBytes == null) return null;

      return await convertPdfToImageBytes(pdfBytes);
    } catch (e) {
      print('Error fetching PDF as image: $e');
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

    if (bill.originalImage!.startsWith('http')) {
      return bill.originalImage;
    }

    return '$baseUrl${bill.originalImage}';
  }

  /// FIXED: Fetch bills with improved error handling
  Future<BillPaginationResult> fetchBills({
    int page = 1,
    int pageSize = 6,
    String? searchQuery,
    String? categoryFilter,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
        'ordering': '-created_at',
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        queryParams['category'] = categoryFilter;
      }

      final uri = Uri.parse(
        '$baseUrl/api/bills/list/',
      ).replace(queryParameters: queryParams);

      print('Fetching bills from: $uri'); // Debug log

      final response = await http.get(uri, headers: headers);

      print('Bills fetch response: ${response.statusCode}'); // Debug log

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

          var allBills = <Bill>[];
          for (int i = 0; i < allBillsJson.length; i++) {
            allBills.add(_safeBillFromJson(allBillsJson[i], index: i));
          }

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

          final paginatedBills =
              filteredBills.skip(startIndex).take(pageSize).toList();

          return BillPaginationResult(
            bills: paginatedBills,
            totalCount: totalCount,
            currentPage: page,
            totalPages: (totalCount / pageSize).ceil(),
          );
        }

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

      _handleHttpError(response, 'Fetch bills');
      throw Exception('Unexpected error');
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow; // Re-throw auth errors
      }
      throw Exception('Error fetching bills: ${e.toString()}');
    }
  }

  /// FIXED: Fetch all bills with better error handling
  Future<List<Bill>> fetchAllBills() async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/api/bills/list/'),
        headers: headers,
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

      _handleHttpError(response, 'Fetch all bills');
      throw Exception('Unexpected error');
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error fetching all bills: ${e.toString()}');
    }
  }

  /// FIXED: Fetch bill by ID with better error handling
  Future<Bill> fetchBillById(int id) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/api/bills/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _safeBillFromJson(data);
      }

      _handleHttpError(response, 'Fetch bill');
      throw Exception('Unexpected error');
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error fetching bill: ${e.toString()}');
    }
  }

  /// FIXED: Create bill with improved multipart handling
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
      // Validate that we have either an image file or web image bytes
      if (imageFile == null && webImageBytes == null) {
        throw Exception(
          'No image provided - image is required for bill creation',
        );
      }

      if (kIsWeb) {
        return _createBillForWeb(
          owner: owner,
          category: category,
          amount: amount,
          paymentDate: paymentDate,
          consumption: consumption,
          items: items,
          webImageBytes: webImageBytes,
        );
      } else {
        return _createBillForMobile(
          owner: owner,
          category: category,
          amount: amount,
          paymentDate: paymentDate,
          consumption: consumption,
          items: items,
          imageFile: imageFile,
        );
      }
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error creating bill: ${e.toString()}');
    }
  }

  /// FIXED: Web implementation with proper authentication
  Future<Bill> _createBillForWeb({
    required String owner,
    required String category,
    required double amount,
    required DateTime paymentDate,
    double? consumption,
    List<Map<String, dynamic>>? items,
    Uint8List? webImageBytes,
  }) async {
    if (webImageBytes == null) {
      throw Exception('No image provided for web');
    }

    final headers = await _getMultipartAuthHeaders();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/bills/'),
    );

    request.headers.addAll(headers);

    // Add basic form fields
    request.fields['owner'] = owner;
    request.fields['category'] = category;
    request.fields['amount'] = amount.toString();
    request.fields['payment_date'] =
        paymentDate.toIso8601String().split('T')[0];

    if (consumption != null) {
      request.fields['consumption'] = consumption.toString();
    }

    // Handle items for purchase bills
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
      print('Sending create bill request to: ${request.url}'); // Debug log
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Create bill response: ${response.statusCode}'); // Debug log

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        return _safeBillFromJson(data);
      }

      // Handle error response
      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to create bills.');
      }

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

  /// FIXED: Mobile implementation with proper authentication
  Future<Bill> _createBillForMobile({
    required String owner,
    required String category,
    required double amount,
    required DateTime paymentDate,
    double? consumption,
    List<Map<String, dynamic>>? items,
    File? imageFile,
  }) async {
    if (imageFile == null) {
      throw Exception('No image file provided for mobile');
    }

    if (!await imageFile.exists()) {
      throw Exception('Image file does not exist');
    }

    final headers = await _getMultipartAuthHeaders();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/bills/'),
    );

    request.headers.addAll(headers);

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
      print('Sending create bill request to: ${request.url}'); // Debug log
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Create bill response: ${response.statusCode}'); // Debug log

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        return _safeBillFromJson(data);
      }

      // Handle error response
      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to create bills.');
      }

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

  /// FIXED: Update bill with better error handling
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
      final headers = await _getAuthHeaders();

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
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _safeBillFromJson(data);
      }

      _handleHttpError(response, 'Update bill');
      throw Exception('Unexpected error');
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error updating bill: ${e.toString()}');
    }
  }

  /// FIXED: Delete bill with better error handling
  Future<void> deleteBill(int billId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/api/bills/$billId/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        _handleHttpError(response, 'Delete bill');
      }
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Error deleting bill: ${e.toString()}');
    }
  }

  // Other helper methods remain the same
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
      print('Error downloading bill PDF: $e');
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
}
