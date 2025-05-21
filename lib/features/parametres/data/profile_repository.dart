import 'dart:io';
import 'package:dio/dio.dart';

class ProfileRepository {
  final Dio _dio;
  final String baseUrl;
  ProfileRepository({required this.baseUrl, Dio? dio}) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String email,
    File? photo, // optional
    String? firstName,
    String? lastName,
    String? tel,
    String? password,
  }) async {
    final form = FormData();

    form.fields
      ..add(MapEntry('username', username))
      ..add(MapEntry('email', email));

    if (firstName != null) form.fields.add(MapEntry('first_name', firstName));
    if (lastName != null) form.fields.add(MapEntry('last_name', lastName));
    if (tel != null) form.fields.add(MapEntry('tel', tel));
    if (password != null) form.fields.add(MapEntry('password', password));

    if (photo != null) {
      form.files.add(
        MapEntry(
          'profile_photo',
          await MultipartFile.fromFile(
            photo.path,
            filename: photo.path.split('/').last,
          ),
        ),
      );
    }

    final resp = await _dio.put(
      '$baseUrl/api/users/me/update/',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return resp.data as Map<String, dynamic>;
  }
}
