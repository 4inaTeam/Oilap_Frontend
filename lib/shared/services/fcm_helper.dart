import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/auth/data/auth_repository.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notification_bloc.dart';
import 'fcm_service.dart';

class FCMIntegrationHelper {
  static final FCMIntegrationHelper _instance = FCMIntegrationHelper._internal();
  factory FCMIntegrationHelper() => _instance;
  FCMIntegrationHelper._internal();

  bool _isInitialized = false;
  final FCMService _fcmService = FCMService();

  // Initialize FCM when app starts
  Future<void> initializeFCM({
    required BuildContext context,
    required AuthRepository authRepository,
    required String baseUrl,
  }) async {
    if (_isInitialized) return;

    try {
      final notificationBloc = context.read<NotificationBloc>();
      
      await _fcmService.initialize(
        authRepository: authRepository,
        notificationBloc: notificationBloc,
        baseUrl: baseUrl,
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  // Handle user login - subscribe to topics
  Future<void> onUserLogin() async {
    if (!_isInitialized) return;

    try {
      await _fcmService.subscribeToUserTopics();
    } catch (e) {
      debugPrint('Error handling FCM on login: $e');
    }
  }

  // Handle user logout - clear FCM data
  Future<void> onUserLogout() async {
    if (!_isInitialized) return;

    try {
      await _fcmService.clearFCMData();
    } catch (e) {
      debugPrint('Error handling FCM on logout: $e');
    }
  }

  // Get FCM service instance
  FCMService get fcmService => _fcmService;

  // Check if FCM is initialized
  bool get isInitialized => _isInitialized;
}

// Extension for easy AuthRepository integration
extension AuthRepositoryFCM on AuthRepository {
  Future<void> loginWithFCM({
    required String identifier,
    required String password,
  }) async {
    // Perform normal login
    await login(identifier: identifier, password: password);
    
    // Handle FCM after successful login
    await FCMIntegrationHelper().onUserLogin();
  }

  Future<void> logoutWithFCM() async {
    // Handle FCM before logout
    await FCMIntegrationHelper().onUserLogout();
    
    // Perform normal logout
    await logout();
  }
}

// Widget to initialize FCM in your app
class FCMInitializer extends StatefulWidget {
  final Widget child;
  final AuthRepository authRepository;
  final String baseUrl;

  const FCMInitializer({
    Key? key,
    required this.child,
    required this.authRepository,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<FCMInitializer> createState() => _FCMInitializerState();
}

class _FCMInitializerState extends State<FCMInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await FCMIntegrationHelper().initializeFCM(
          context: context,
          authRepository: widget.authRepository,
          baseUrl: widget.baseUrl,
        );

        // If user is already logged in, subscribe to topics
        final hasValidTokens = await widget.authRepository.hasValidTokens();
        if (hasValidTokens) {
          await FCMIntegrationHelper().onUserLogin();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Notification permission dialog
class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Activer les notifications'),
      content: const Text(
        'Voulez-vous recevoir des notifications pour rester informé des mises à jour importantes?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Plus tard'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Activer'),
        ),
      ],
    );
  }

  // Show permission dialog
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const NotificationPermissionDialog(),
    );
    return result ?? false;
  }
}

// Settings widget for notification preferences
class NotificationSettings extends StatefulWidget {
  const NotificationSettings({Key? key}) : super(key: key);

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _notificationsEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final enabled = await FCMService().areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggleNotifications() async {
    if (_notificationsEnabled) {
      // If currently enabled, show info about disabling in system settings
      _showSystemSettingsInfo();
    } else {
      // Request permission
      final granted = await FCMService().requestPermissionAgain();
      if (mounted) {
        setState(() {
          _notificationsEnabled = granted;
        });
      }
    }
  }

  void _showSystemSettingsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Désactiver les notifications'),
        content: const Text(
          'Pour désactiver les notifications, veuillez aller dans les paramètres de votre appareil > Applications > Votre App > Notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ListTile(
        title: Text('Notifications'),
        trailing: CircularProgressIndicator(),
      );
    }

    return SwitchListTile(
      title: const Text('Notifications push'),
      subtitle: Text(
        _notificationsEnabled 
          ? 'Recevoir les notifications importantes'
          : 'Activez pour recevoir les notifications',
      ),
      value: _notificationsEnabled,
      onChanged: (_) => _toggleNotifications(),
    );
  }
}