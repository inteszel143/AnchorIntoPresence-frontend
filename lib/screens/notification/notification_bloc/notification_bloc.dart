import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<FetchNotifications>((event, emit) async {
      emit(NotificationLoading());

      try {
        final notifications = await ApiService.fetchNotifications();

        emit(NotificationLoaded(notifications: notifications));
      } catch (e) {
        emit(NotificationError(errorMessage: 'An error occurred: $e'));
      }
    });
  }
}
