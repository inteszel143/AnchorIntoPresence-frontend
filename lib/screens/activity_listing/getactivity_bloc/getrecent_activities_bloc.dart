import 'dart:io';

import 'package:bloc/bloc.dart';

import '../../../utils/api_service.dart';
import 'getrecent_activities_event.dart';
import 'getrecent_activities_state.dart';

// Manages activity listing, activity details, and favorite status operations.
class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc() : super(ActivityInitial()) {
    on<FetchActivities>(_onFetchActivities);
    on<FetchActivity>(_onFetchActivity);
    on<ToggleFavorite>(_onToggleFavorite);
  }
// Fetches the activity list with pagination, search, sorting, and category filters.
  Future<void> _onFetchActivities(
      FetchActivities event, Emitter<ActivityState> emit) async {
    emit(ActivityLoading());
    try {
      final activities = await ApiService.fetchActivities(event.page,
          event.limit, event.search, event.sortOrder, event.categoryId, null);
      emit(ActivityLoaded(activities));
    } on SocketException {
      emit(ActivityError('Please check your internet connection'));
    } catch (e) {
      emit(ActivityError("Error: $e"));
    }
  }

// Fetches the details of a selected activity using its activity ID.
  Future<void> _onFetchActivity(
      FetchActivity event, Emitter<ActivityState> emit) async {
    emit(ActivityLoading());
    try {
      final activities = await ApiService.fetchActivity(event.activityId);
      emit(ActivityLoad(activities));
    } on SocketException {
      emit(ActivityError('Please check your internet connection'));
    } catch (e) {
      emit(ActivityError("Error: $e"));
    }
  }

// Updates the favorite status of the selected activity.
  Future<void> _onToggleFavorite(
      ToggleFavorite event, Emitter<ActivityState> emit) async {
    try {
      final message = await ApiService.toggleFavorite(event.activityId);
      emit(ActivityFavouriteLoaded(message));
    } catch (e) {}
  }
}
