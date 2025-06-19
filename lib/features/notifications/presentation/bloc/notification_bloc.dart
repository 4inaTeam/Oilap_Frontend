import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/features/notifications/data/notification_repository.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notification_event.dart';
import 'package:oilab_frontend/features/notifications/presentation/bloc/notifications_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  NotificationBloc(this.repository) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<AddNewNotification>(_onAddNewNotification);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      if (event.refresh || state is NotificationInitial) {
        emit(NotificationLoading());
      }

      final notifications = await repository.getNotifications();
      final unreadCount = await repository.getUnreadCount();

      _notifications = notifications;
      _unreadCount = unreadCount;

      emit(
        NotificationLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
        ),
      );
    } catch (e) {
      log('Error loading notifications: $e');
      emit(NotificationError('Failed to load notifications'));
    }
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final unreadCount = await repository.getUnreadCount();
      _unreadCount = unreadCount;

      if (state is NotificationLoaded) {
        emit(
          NotificationLoaded(
            notifications: _notifications,
            unreadCount: _unreadCount,
          ),
        );
      }
    } catch (e) {
      log('Error loading unread count: $e');
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final success = await repository.markAsRead(event.notificationId);

      if (success) {
        // Update local state
        _notifications =
            _notifications.map((notification) {
              if (notification.id == event.notificationId) {
                return notification.copyWith(isRead: true);
              }
              return notification;
            }).toList();

        // Decrease unread count if notification was unread
        final wasUnread =
            _notifications
                .firstWhere((n) => n.id == event.notificationId)
                .isRead ==
            false;

        if (wasUnread) {
          _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
        }

        emit(
          NotificationLoaded(
            notifications: _notifications,
            unreadCount: _unreadCount,
          ),
        );
      }
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final success = await repository.markAllAsRead();

      if (success) {
        // Update local state
        _notifications =
            _notifications
                .map((notification) => notification.copyWith(isRead: true))
                .toList();
        _unreadCount = 0;

        emit(
          NotificationLoaded(
            notifications: _notifications,
            unreadCount: _unreadCount,
          ),
        );
      }
    } catch (e) {
      log('Error marking all notifications as read: $e');
    }
  }

  Future<void> _onAddNewNotification(
    AddNewNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Create notification from FCM data
      final notification = NotificationModel(
        id:
            event.notificationData['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.notificationData['title'] ?? 'New Notification',
        body: event.notificationData['body'] ?? '',
        type: event.notificationData['type'] ?? 'general',
        data: event.notificationData,
        createdAt: DateTime.now(),
        isRead: false,
      );

      // Add to the beginning of the list
      _notifications = [notification, ..._notifications];
      _unreadCount++;

      emit(
        NotificationLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
        ),
      );
    } catch (e) {
      log('Error adding new notification: $e');
    }
  }
}
