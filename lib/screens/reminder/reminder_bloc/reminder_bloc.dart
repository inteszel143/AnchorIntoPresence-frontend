import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../utils/api_service.dart';
import '../reminder_model.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  int _hour = 0;
  int _minute = 0;
  ReminderBloc() : super(ReminderInitial()) {
    on<SetReminder>(_onSetReminder);
    on<TimeChangedEvent>(_handleTimeChanged);
    on<FetchReminder>(_onFetchReminder);
    on<UpdateReminder>(_onUpdateReminder);
    on<DeleteReminder>(_onDeleteReminder);
  }

  void _handleTimeChanged(TimeChangedEvent event, Emitter<ReminderState> emit) {
    _hour = event.hour;
    _minute = event.minute;
    emit(TimeChangedState(hour: _hour, minute: _minute));
  }

  FutureOr<void> _onSetReminder(
      SetReminder event, Emitter<ReminderState> emit) async {
    try {
      emit(ReminderLoading());
      print('ReminderSettingInProgress emitted:${event.reminderData}');

      final response = await ApiService.setReminder(event.reminderData);
      final statusCode = response['statusCode'];

      if (statusCode == 200) {
        final data = response['body'];
        print('Response Data: $data');
        emit(ReminderLoaded(message: data['message']));
        print('ReminderSettingSuccess emitted');
      } else {
        emit(ReminderFailed(error: 'Failed to set reminder'));
      }
    } catch (e) {
      emit(ReminderFailed(error: 'Error: $e'));
    }
  }

  FutureOr<void> _onFetchReminder(
      FetchReminder event, Emitter<ReminderState> emit) async {
    emit(ReminderLoading());
    try {
      final response = await ApiService.getReminder();
      final statusCode = response['statusCode'];

      if (statusCode == 200) {
        final List<dynamic> data = response['body']['data'] ?? [];

        final List<ReminderModel> reminders = data.map((item) {
          return ReminderModel(
            id: item['_id'],
            time: item['time'],
            createdAt: item['createdAt'] != null
                ? DateTime.parse(item['createdAt'])
                : null,
            weekdays: (item['weekday'] as List)
                .map((e) => int.tryParse(e.toString()) ?? 0)
                .toList(),
            date: item['date'] != null ? DateTime.parse(item['date']) : null,
          );
        }).toList();
        print('reminders:$reminders');
        emit(ReminderFetchSuccess(reminders: reminders));
      } else {
        emit(ReminderFailed(error: 'Failed to fetch reminder'));
      }
    } catch (e) {
      emit(ReminderFailed(error: 'Error fetching reminder: $e'));
    }
  }

  FutureOr<void> _onUpdateReminder(
      UpdateReminder event, Emitter<ReminderState> emit) async {
    emit(ReminderLoading());
    try {
      final response = await ApiService.updateReminder(event.reminderData);

      final statusCode = response['statusCode'];
      final message = response['body']['message'];

      if (statusCode == 200) {
        emit(ReminderUpdateSuccess(message: message));
        //add(FetchReminder());
      } else {
        emit(ReminderFailed(error: message ?? 'Failed to update reminder'));
      }
    } catch (e) {
      emit(ReminderFailed(error: 'Error updating reminder: $e'));
    }
  }

  Future<void> _onDeleteReminder(
      DeleteReminder event, Emitter<ReminderState> emit) async {
    emit(ReminderDeleteInProgress());

    try {
      final success = await ApiService.deleteReminder(event.id);
      if (success) {
        add(FetchReminder());
        emit(ReminderDeleteSuccess());
      } else {
        emit(ReminderDeleteFailure('Failed to delete reminder'));
      }
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(ReminderDeleteFailure(errorMessage));
    }
  }
}
