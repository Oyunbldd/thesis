import '../models/notification_model.dart';

class NotificationController {
  final List<NotificationModel> _notifications = [];

  void addNotification(NotificationModel notification) {
    _notifications.add(notification);
  }

  List<NotificationModel> getUserNotifications(String userId) {
    return _notifications
        .where((notification) => notification.userId == userId)
        .toList();
  }

  void markAsRead(String notificationId) {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].id == notificationId) {
        final notification = _notifications[i];

        _notifications[i] = NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          userId: notification.userId,
          createdAt: notification.createdAt,
          isRead: true,
        );
        break;
      }
    }
  }
}
