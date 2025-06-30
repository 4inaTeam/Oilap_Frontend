import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:oilab_frontend/features/notifications/data/notification_repository.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notification_event.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        context.read<NotificationBloc>().add(LoadNotifications(refresh: true));
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Safely handle back navigation
        _isDisposed = true;
        return true;
      },
      child: AppLayout(
        currentRoute: '/notifications',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            return Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 12 : 16),
                  Expanded(
                    child: _NotificationContent(
                      isMobile: isMobile,
                      isDisposed: () => _isDisposed,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  final bool isMobile;
  final bool Function() isDisposed;

  const _NotificationContent({
    required this.isMobile,
    required this.isDisposed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is NotificationLoaded) {
          if (state.notifications.isEmpty) {
            return const _EmptyNotificationsState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (!isDisposed()) {
                context.read<NotificationBloc>().add(
                  LoadNotifications(refresh: true),
                );
              }
            },
            child: ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationItem(
                  notification: notification,
                  isMobile: isMobile,
                  onTap: () => _handleNotificationTap(context, notification),
                  isDisposed: isDisposed,
                );
              },
            ),
          );
        }

        if (state is NotificationError) {
          return _ErrorState(
            message: state.message,
            onRetry: () {
              if (!isDisposed()) {
                context.read<NotificationBloc>().add(
                  LoadNotifications(refresh: true),
                );
              }
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Check if widget is still mounted before performing actions
    if (isDisposed()) return;

    // Mark as read if not already read
    if (!notification.isRead) {
      try {
        context.read<NotificationBloc>().add(
          MarkNotificationAsRead(notification.id),
        );
      } catch (e) {
        // Silently handle bloc access errors if widget is disposed
        return;
      }
    }

    // Handle navigation based on notification type
    final String? notificationType = notification.type;
    final String? route = notification.data['route'];
    final String? factureId = notification.data['id'];

    switch (notificationType) {
      case 'facture':
        if (route != null && factureId != null) {
          // Navigate to facture detail
          // You'll need to implement this navigation based on your app structure
          // Example: NavigationService.navigateTo(route, arguments: {'id': factureId});
          _showFactureDialog(context, factureId);
        }
        break;
      case 'test':
        if (!isDisposed()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test notification received')),
          );
        }
        break;
      default:
        // Handle other notification types
        break;
    }
  }

  void _showFactureDialog(BuildContext context, String factureId) {
    if (isDisposed()) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Facture Notification'),
            content: Text('Navigate to facture with ID: $factureId'),
            actions: [
              TextButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final bool isMobile;
  final VoidCallback onTap;
  final bool Function() isDisposed;

  const _NotificationItem({
    required this.notification,
    required this.isMobile,
    required this.onTap,
    required this.isDisposed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notification.isRead ? Colors.white : Colors.blue.shade50,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
            size: isMobile ? 20 : 24,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing:
            notification.isRead
                ? null
                : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
        onTap: () {
          // Check if the widget is still valid before handling tap
          if (!isDisposed()) {
            onTap();
          }
        },
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'facture':
        return Colors.green;
      case 'test':
        return Colors.blue;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'facture':
        return Icons.receipt;
      case 'test':
        return Icons.notifications;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Maintenant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} heures';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'avez pas encore reçu de notifications',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
