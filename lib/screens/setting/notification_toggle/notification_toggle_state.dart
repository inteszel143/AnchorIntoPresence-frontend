abstract class NotificationToggleState {}

class NotificationToggleInitial extends NotificationToggleState {}

class NotificationToggleLoading extends NotificationToggleState {}

class NotificationToggleSuccess extends NotificationToggleState {
  final String message;

  NotificationToggleSuccess(this.message);
}

class NotificationToggleError extends NotificationToggleState {
  final String message;

  NotificationToggleError(this.message);
}
