import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      data: json['data'] ?? {},
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationRepository {
  final String baseUrl;
  final AuthRepository authRepo;

  NotificationRepository({required this.baseUrl, required this.authRepo});

  // Update FCM token
  Future<bool> updateFcmToken(String token) async {
    try {
      final authToken = await authRepo.getAccessToken();
      if (authToken == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/tickets/update-fcm-token/'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      return response.statusCode == 200;
    } catch (e) {
      log('Error updating FCM token: $e');
      return false;
    }
  }

  // Test push notification
  Future<bool> testPushNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final authToken = await authRepo.getAccessToken();
      if (authToken == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/tickets/test-push/'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'data': data ?? {},
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      log('Error sending test push notification: $e');
      return false;
    }
  }

  // Debug FCM token
  Future<Map<String, dynamic>?> debugFcmToken() async {
    try {
      final authToken = await authRepo.getAccessToken();
      if (authToken == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/tickets/debug-fcm-token/'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to debug FCM token: ${response.statusCode}');
      }
    } catch (e) {
      log('Error debugging FCM token: $e');
      return null;
    }
  }

  // Note: The following methods would require additional Django views to be implemented
  // These are placeholder implementations that would work once you add the corresponding Django endpoints

  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/tickets/notifications/?page=$page&page_size=$pageSize'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> notifications = data['results'] ?? [];
        return notifications
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      log('Error loading notifications: $e');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/tickets/notifications/unread-count/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting unread count: $e');
      return 0;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/tickets/notifications/$notificationId/mark-read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      log('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final token = await authRepo.getAccessToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/tickets/notifications/mark-all-read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      log('Error marking all notifications as read: $e');
      return false;
    }
  }
}