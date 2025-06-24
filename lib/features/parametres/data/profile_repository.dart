import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/models/user_model.dart';
import '../../auth/data/auth_repository.dart';

class ProfileRepository {
  final String baseUrl;
  final AuthRepository _authRepo;

  ProfileRepository({
    required this.baseUrl,
    required AuthRepository authRepository,
  }) : _authRepo = authRepository;

  Future<http.Response> _makeAuthenticatedRequest(
    Future<http.Response> Function(String token) requestFunction,
  ) async {
    String? token = await _authRepo.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    var response = await requestFunction(token);

    if (response.statusCode == 401) {
      final newToken = await _authRepo.refreshAccessToken();
      if (newToken != null) {
        response = await requestFunction(newToken);
      } else {
        throw Exception('Authentication failed - please login again');
      }
    }

    return response;
  }

  Future<http.Response> _makeAuthenticatedMultipartRequest(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    String? token = await _authRepo.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    var request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    request.files.addAll(files);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 401) {
      final newToken = await _authRepo.refreshAccessToken();
      if (newToken != null) {
        var retryRequest = http.MultipartRequest('PATCH', uri);
        retryRequest.headers['Authorization'] = 'Bearer $newToken';
        retryRequest.fields.addAll(fields);
        retryRequest.files.addAll(files);

        var retryStreamedResponse = await retryRequest.send();
        response = await http.Response.fromStream(retryStreamedResponse);
      } else {
        throw Exception('Authentication failed - please login again');
      }
    }

    return response;
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _makeAuthenticatedRequest(
        (token) => http.get(
          Uri.parse('$baseUrl/api/users/me/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return User.fromJson(jsonData);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to load user profile: $errorMessage');
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      throw Exception('Error loading user profile: $e');
    }
  }

  Future<User> updateProfile({
    required String name,
    required String email,
    required String cin,
    String? tel,
    String? password,
    File? profilePhoto,
    Uint8List? profilePhotoBytes, // Add this parameter for web support
  }) async {
    try {
      final fields = <String, String>{
        'name': name,
        'email': email,
        'cin': cin,
      };

      if (tel != null && tel.isNotEmpty) {
        fields['tel'] = tel;
      }

      if (password != null && password.isNotEmpty) {
        fields['password'] = password;
      }

      final files = <http.MultipartFile>[];
      
      // Handle profile photo for both web and mobile
      if (kIsWeb && profilePhotoBytes != null) {
        // Web: use bytes
        final profilePhotoField = http.MultipartFile.fromBytes(
          'profile_photo',
          profilePhotoBytes,
          filename: 'profile_photo.jpg',
        );
        files.add(profilePhotoField);
      } else if (!kIsWeb && profilePhoto != null) {
        // Mobile: use file path
        final profilePhotoField = await http.MultipartFile.fromPath(
          'profile_photo',
          profilePhoto.path,
        );
        files.add(profilePhotoField);
      }

      final response = await _makeAuthenticatedMultipartRequest(
        '/api/users/me/update/',
        fields,
        files,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return User.fromJson(jsonData);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to update profile: $errorMessage');
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      throw Exception('Error updating profile: $e');
    }
  }

  Future<void> updateProfilePhoto(File? photo, {Uint8List? photoBytes}) async {
    try {
      final files = <http.MultipartFile>[];
      
      if (kIsWeb && photoBytes != null) {
        // Web: use bytes
        final profilePhotoField = http.MultipartFile.fromBytes(
          'profile_photo',
          photoBytes,
          filename: 'profile_photo.jpg',
        );
        files.add(profilePhotoField);
      } else if (!kIsWeb && photo != null) {
        // Mobile: use file path
        final profilePhotoField = await http.MultipartFile.fromPath(
          'profile_photo',
          photo.path,
        );
        files.add(profilePhotoField);
      }

      final response = await _makeAuthenticatedMultipartRequest(
        '/api/users/me/update/',
        <String, String>{},
        files,
      );

      if (response.statusCode != 200) {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to update profile photo: $errorMessage');
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      throw Exception('Error updating profile photo: $e');
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map<String, dynamic>) {
        if (errorData.containsKey('detail')) {
          return errorData['detail'].toString();
        }
        if (errorData.containsKey('message')) {
          return errorData['message'].toString();
        }
        if (errorData.containsKey('error')) {
          return errorData['error'].toString();
        }
        final fieldErrors = <String>[];
        errorData.forEach((key, value) {
          if (value is List) {
            fieldErrors.add('$key: ${value.join(', ')}');
          } else if (value is String) {
            fieldErrors.add('$key: $value');
          }
        });
        if (fieldErrors.isNotEmpty) {
          return fieldErrors.join('; ');
        }
      }
      return 'HTTP ${response.statusCode}';
    } catch (e) {
      return 'HTTP ${response.statusCode}: ${response.body}';
    }
  }
}