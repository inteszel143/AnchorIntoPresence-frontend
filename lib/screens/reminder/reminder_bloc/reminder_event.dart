part of 'reminder_bloc.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();
}

class SetReminder extends ReminderEvent {
  final Map<String, dynamic> reminderData;

  const SetReminder({required this.reminderData});

  @override
  List<Object?> get props => [reminderData];
}
class TimeChangedEvent extends ReminderEvent {
  final int hour;
  final int minute;
  const TimeChangedEvent({required this.hour, required this.minute});

  @override
  List<Object?> get props => [hour,minute];
}

class FetchReminder extends ReminderEvent {
  const FetchReminder();

  @override
  List<Object?> get props => [];
}


class UpdateReminder extends ReminderEvent {
  final Map<String, dynamic> reminderData;

  const UpdateReminder({
    required this.reminderData
  });

  @override
  List<Object?> get props => [reminderData];
}
class DeleteReminder extends ReminderEvent {
  final String id;
  const DeleteReminder(this.id);
  @override
  List<Object?> get props => [id];
}