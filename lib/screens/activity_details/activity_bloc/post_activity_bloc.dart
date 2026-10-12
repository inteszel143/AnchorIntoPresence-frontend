import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/activity_details/activity_bloc/post_activity_event.dart';
import 'package:mindfully_evolve_app/screens/activity_details/activity_bloc/post_activity_state.dart';

import '../../../utils/api_service.dart';
import '../activityresponse_model.dart';
import '../../track/activity_log_updates.dart';

// Manages the activity completion submission flow and its related states.
class PostActivityBloc extends Bloc<PostActivityEvent, PostActivityState> {
  PostActivityBloc({Future<PostActivityResponseModel> Function(MarkActivityComplete)? submit})
      : _submit = submit, super(PostActivityInitial()) {
    on<MarkActivityComplete>(_onMarkActivityComplete);
  }

  final Future<PostActivityResponseModel> Function(MarkActivityComplete)? _submit;

  Future<void> _onMarkActivityComplete(
    MarkActivityComplete event,
    Emitter<PostActivityState> emit,
  ) async {
    // Indicates that the activity completion request is being submitted.
    emit(PostActivitySubmitting());

    try {
      // Sends the user's activity progress and completion status to the backend.
      final postActivityResponse = _submit != null
          ? await _submit(event)
          : await ApiService.markActivityComplete(
        activityId: event.activityId,
        videoTimestamp: event.videoTimestamp,
        totalVideoTime: event.totalVideoTime,
        isCompleted: event.isCompleted,
      );

      if (!postActivityResponse.status ||
          (event.isCompleted && !postActivityResponse.data.isCompleted)) {
        throw Exception('Your practice was not saved. Please try again.');
      }
      activityLogRevision.value++;
      emit(PostActivitySuccess(
        response: postActivityResponse,
        isCompleted: event.isCompleted,
      ));
    }
    // Handles connectivity issues separately to provide a user-friendly error message.
    on SocketException catch (_) {
      emit(PostActivityFailure(error: 'Please check your internet connection', isCompletion: event.isCompleted));
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(PostActivityFailure(error: errorMessage, isCompletion: event.isCompleted));
    }
  }
}
