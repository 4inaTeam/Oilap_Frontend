abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {
  final bool refresh;
  LoadNotifications({this.refresh = false});
}

class LoadUnreadCount extends NotificationEvent {}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;
  MarkNotificationAsRead(this.notificationId);
}

class MarkAllNotificationsAsRead extends NotificationEvent {}

class AddNewNotification extends NotificationEvent {
  final Map<String, dynamic> notificationData;
  AddNewNotification(this.notificationData);
}
