import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mindfully_evolve_app/common/local_storage.dart';
import 'package:mindfully_evolve_app/utils/urls.dart';

import 'notification_toggle_event.dart';
import 'notification_toggle_state.dart';

class NotificationToggleBloc
    extends Bloc<NotificationToggleEvent, NotificationToggleState> {
  NotificationToggleBloc() : super(NotificationToggleInitial()) {
    on<ToggleNotificationEvent>(_onToggleNotificationEvent);
  }

  Future<void> _onToggleNotificationEvent(ToggleNotificationEvent event,
      Emitter<NotificationToggleState> emit) async {
    emit(NotificationToggleLoading());

    try {
      final token = await LocalStorage.getToken() ?? '';
      final response = await _toggleNotification(token, event.isEnabled);

      if (response.statusCode == 200) {
        emit(NotificationToggleSuccess('Notification updates successfully.'));
      } else {
        emit(NotificationToggleError('Failed to update notification setting'));
      }
    } catch (e) {
      emit(NotificationToggleError('Error: $e'));
    }
  }

  // API call to toggle notifications
  Future<http.Response> _toggleNotification(
      String token, bool isEnabled) async {
    final url = Urls.updateNotification;
    return await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: '{"status": "${isEnabled ? 'true' : 'false'}"}',
    );
  }
}
