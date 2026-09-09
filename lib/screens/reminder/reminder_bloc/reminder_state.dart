part of 'reminder_bloc.dart';

sealed class ReminderState extends Equatable {
  const ReminderState();
}

final class ReminderInitial extends ReminderState {
  @override
  List<Object> get props => [];
}

final class ReminderLoading extends ReminderState {
  @override
  List<Object> get props => [];
}

final class ReminderLoaded extends ReminderState {
  final String message;

  const ReminderLoaded({required this.message});

  @override
  List<Object> get props => [message];
}

final class ReminderFailed extends ReminderState {
  final String error;

  ReminderFailed({required this.error});

  @override
  List<Object> get props => [error];
}
final class TimeChangedState extends ReminderState {
  final int hour;
  final int minute;

  TimeChangedState({required this.hour, required this.minute});

  @override
  List<Object> get props => [hour,minute];
}

final class ReminderFetchSuccess extends ReminderState {
  final List<ReminderModel> reminders;

  ReminderFetchSuccess({required this.reminders});

  @override
  List<Object> get props => [reminders];
}
class ReminderUpdateSuccess extends ReminderState {
  final String message;

  ReminderUpdateSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class ReminderDeleteInProgress extends ReminderState {
  @override
  List<Object> get props => [];
}

class ReminderDeleteSuccess extends ReminderState {
  @override
  List<Object> get props => [];
}

class ReminderDeleteFailure extends ReminderState {
  final String error;
  ReminderDeleteFailure(this.error);
  @override
  List<Object> get props => [error];
}