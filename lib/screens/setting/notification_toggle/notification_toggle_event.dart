abstract class NotificationToggleEvent {}

class ToggleNotificationEvent extends NotificationToggleEvent {
  final bool isEnabled;

  ToggleNotificationEvent(this.isEnabled);
}
