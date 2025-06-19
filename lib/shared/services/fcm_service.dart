import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notification_event.dart';
import 'package:oilab_frontend/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.messageId}');

}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _tokenKey = 'fcm_token';
  String? _currentToken;
  AuthRepository? _authRepository;
  NotificationBloc? _notificationBloc;
  String? _baseUrl;

  // Initialize FCM Service
  Future<void> initialize({
    required AuthRepository authRepository,
    required NotificationBloc notificationBloc,
    required String baseUrl,
  }) async {
    _authRepository = authRepository;
    _notificationBloc = notificationBloc;
    _baseUrl = baseUrl;

    try {
      // Request permission for iOS
      await _requestPermission();

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Get initial token
      await _getAndStoreToken();

      // Set up message handlers
      _setupMessageHandlers();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);

      log('FCM Service initialized successfully');
    } catch (e) {
      log('Error initializing FCM Service: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      log('User granted permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        log('User granted provisional permission');
      } else {
        log('User declined or has not accepted permission');
      }
    } catch (e) {
      log('Error requesting permission: $e');
    }
  }

  // Get and store FCM token
  Future<void> _getAndStoreToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        _currentToken = token;
        await _storeTokenLocally(token);
        await _sendTokenToServer(token);
        log('FCM Token obtained: $token');
      }
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  // Store token locally
  Future<void> _storeTokenLocally(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      log('Error storing token locally: $e');
    }
  }

  // Get stored token
  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      log('Error getting stored token: $e');
      return null;
    }
  }

  // Send token to server
  Future<void> _sendTokenToServer(String token) async {
    if (_authRepository == null || _baseUrl == null) return;

    try {
      final accessToken = await _authRepository!.getAccessToken();
      if (accessToken == null) {
        log('No access token available for sending FCM token');
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/fcm-token/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
          'device_type':
              defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('FCM token sent to server successfully');
      } else {
        log(
          'Failed to send FCM token to server: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      log('Error sending FCM token to server: $e');
    }
  }

  // Handle token refresh
  Future<void> _onTokenRefresh(String token) async {
    log('FCM Token refreshed: $token');
    _currentToken = token;
    await _storeTokenLocally(token);
    await _sendTokenToServer(token);
  }

  // Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle initial message when app is launched from notification
    _handleInitialMessage();
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Received foreground message: ${message.messageId}');

    // Refresh notifications in the bloc
    _notificationBloc?.add(LoadNotifications(refresh: true));
    _notificationBloc?.add(LoadUnreadCount());

    // Show local notification if needed
    _showLocalNotification(message);
  }

  // Handle message when app is opened from notification
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    log('App opened from notification: ${message.messageId}');

    // Refresh notifications
    _notificationBloc?.add(LoadNotifications(refresh: true));

    // Navigate to notification screen or specific content
    await _handleNotificationNavigation(message);
  }

  // Handle initial message when app is launched from notification
  Future<void> _handleInitialMessage() async {
    try {
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        log('App launched from notification: ${initialMessage.messageId}');
        // Handle navigation after app is ready
        await _handleNotificationNavigation(initialMessage);
      }
    } catch (e) {
      log('Error handling initial message: $e');
    }
  }

  // Show local notification for foreground messages
  void _showLocalNotification(RemoteMessage message) {
    // This will be handled by the system notification or you can use
    // flutter_local_notifications plugin for custom local notifications
    log('Showing local notification: ${message.notification?.title}');
  }

  // Handle navigation based on notification data
  Future<void> _handleNotificationNavigation(RemoteMessage message) async {
    final data = message.data;
    final context = _getNavigationContext();

    if (context == null) return;

    // Navigate based on notification type
    switch (data['type']) {
      case 'facture':
        final factureId = data['facture_id'];
        if (factureId != null) {
          // Navigate to facture detail
          _navigateToFacture(context, factureId);
        }
        break;
      case 'general':
        // Navigate to notifications screen
        _navigateToNotifications(context);
        break;
      default:
        // Default to notifications screen
        _navigateToNotifications(context);
        break;
    }
  }

  // Get navigation context (you'll need to implement this based on your app structure)
  BuildContext? _getNavigationContext() {
    // Return the current context from your navigation service or global key
    // This is a placeholder - implement based on your app's navigation setup
    return null;
  }

  // Navigate to facture detail
  void _navigateToFacture(BuildContext context, String factureId) {
    // Implement navigation to facture detail screen
    // Example: Navigator.pushNamed(context, '/facture/$factureId');
    log('Navigate to facture: $factureId');
  }

  // Navigate to notifications screen
  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  // Get current FCM token
  String? get currentToken => _currentToken;

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic $topic: $e');
    }
  }

  // Subscribe to user-specific topics based on role
  Future<void> subscribeToUserTopics() async {
    if (_authRepository == null) return;

    try {
      final role = AuthRepository.currentRole;
      final userId = AuthRepository.currentUserId;

      if (role != null) {
        await subscribeToTopic('role_$role');
      }

      if (userId != null) {
        await subscribeToTopic('user_$userId');
      }

      // Subscribe to general topics
      await subscribeToTopic('general');
    } catch (e) {
      log('Error subscribing to user topics: $e');
    }
  }

  // Unsubscribe from all topics (call on logout)
  Future<void> unsubscribeFromAllTopics() async {
    try {
      final role = AuthRepository.currentRole;
      final userId = AuthRepository.currentUserId;

      if (role != null) {
        await unsubscribeFromTopic('role_$role');
      }

      if (userId != null) {
        await unsubscribeFromTopic('user_$userId');
      }

      await unsubscribeFromTopic('general');
    } catch (e) {
      log('Error unsubscribing from topics: $e');
    }
  }

  // Clear FCM data (call on logout)
  Future<void> clearFCMData() async {
    try {
      await unsubscribeFromAllTopics();
      await _deleteTokenFromServer();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);

      _currentToken = null;
      log('FCM data cleared');
    } catch (e) {
      log('Error clearing FCM data: $e');
    }
  }

  // Delete token from server
  Future<void> _deleteTokenFromServer() async {
    if (_authRepository == null || _baseUrl == null || _currentToken == null)
      return;

    try {
      final accessToken = await _authRepository!.getAccessToken();
      if (accessToken == null) return;

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/users/fcm-token/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fcm_token': _currentToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('FCM token deleted from server successfully');
      } else {
        log('Failed to delete FCM token from server: ${response.statusCode}');
      }
    } catch (e) {
      log('Error deleting FCM token from server: $e');
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      log('Error checking notification settings: $e');
      return false;
    }
  }

  // Request permission again (for settings)
  Future<bool> requestPermissionAgain() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      log('Error requesting permission: $e');
      return false;
    }
  }
}
