

import '../notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;
  NotificationLoaded({required this.notifications});
}

class NotificationError extends NotificationState {
  final String errorMessage;
  NotificationError({required this.errorMessage});
}
