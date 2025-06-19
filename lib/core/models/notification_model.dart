import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body; 
  final String? type;
  final bool isRead;
  final DateTime sentAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type,
    required this.isRead,
    required this.sentAt,
    this.data,
  });

  // Factory constructor for JSON data (from HTTP API)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['message']?.toString() ?? json['body']?.toString() ?? '',
      type: json['type']?.toString(),
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      sentAt: _parseDateTime(json['sent_at'] ?? json['sentAt']),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  // Factory constructor for Firestore document
  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: doc.id,
      userId: data['user_id']?.toString() ?? data['userId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      body: data['message']?.toString() ?? data['body']?.toString() ?? '',
      type: data['type']?.toString(),
      isRead: data['is_read'] ?? data['isRead'] ?? false,
      sentAt: _parseFirestoreDateTime(data['sent_at'] ?? data['sentAt']),
      data: data['data'] as Map<String, dynamic>?,
    );
  }

  // Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is DateTime) return dateValue;

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }

    if (dateValue is int) {
      // Assume it's milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }

    return DateTime.now();
  }

  // Helper method to parse DateTime from Firestore Timestamp
  static DateTime _parseFirestoreDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is Timestamp) return dateValue.toDate();

    if (dateValue is DateTime) return dateValue;

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }

    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }

    return DateTime.now();
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': body, // API expects 'message'
      'type': type,
      'is_read': isRead,
      'sent_at': sentAt.toIso8601String(),
      'data': data,
    };
  }

  // Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'title': title,
      'message': body,
      'type': type,
      'is_read': isRead,
      'sent_at': Timestamp.fromDate(sentAt),
      'data': data,
    };
  }

  // Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? sentAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.isRead == isRead &&
        other.sentAt == sentAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, title, body, type, isRead, sentAt);
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, title: $title, body: $body, type: $type, isRead: $isRead, sentAt: $sentAt)';
  }
}
