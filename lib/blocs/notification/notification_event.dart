abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotifications extends NotificationEvent {
  final bool refresh;
  const LoadNotifications({this.refresh = false});
}

class MarkAsRead extends NotificationEvent {
  final int id;
  const MarkAsRead(this.id);
}

class MarkAllAsRead extends NotificationEvent {
  const MarkAllAsRead();
}
