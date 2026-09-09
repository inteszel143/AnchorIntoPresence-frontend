import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/activity_details/activity_bloc/post_activity_event.dart';
import 'package:mindfully_evolve_app/screens/activity_details/activity_bloc/post_activity_state.dart';

import '../../../utils/api_service.dart';

// Manages the activity completion submission flow and its related states.
class PostActivityBloc extends Bloc<PostActivityEvent, PostActivityState> {
  PostActivityBloc() : super(PostActivityInitial()) {
    on<MarkActivityComplete>(_onMarkActivityComplete);
  }

  Future<void> _onMarkActivityComplete(
    MarkActivityComplete event,
    Emitter<PostActivityState> emit,
  ) async {
    // Indicates that the activity completion request is being submitted.
    emit(PostActivitySubmitting());

    try {
      // Sends the user's activity progress and completion status to the backend.
      final postActivityResponse = await ApiService.markActivityComplete(
        activityId: event.activityId,
        videoTimestamp: event.videoTimestamp,
        totalVideoTime: event.totalVideoTime,
        isCompleted: event.isCompleted,
      );

      emit(PostActivitySuccess(
        response: postActivityResponse,
        isCompleted: event.isCompleted,
      ));
    }
    // Handles connectivity issues separately to provide a user-friendly error message.
    on SocketException catch (_) {
      emit(PostActivityFailure(error: 'Please check your internet connection'));
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(PostActivityFailure(error: errorMessage));
    }
  }
}
