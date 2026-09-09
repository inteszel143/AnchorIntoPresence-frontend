import 'dart:convert';
import '../activity_list_cache.dart';
import '../getactivity_model.dart';
import 'dart:io';

import 'package:bloc/bloc.dart';

import '../../../utils/api_service.dart';
import 'getrecent_activities_event.dart';
import 'getrecent_activities_state.dart';

// Manages activity listing, activity details, and favorite status operations.
class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityResponse? _lastList;

  ActivityBloc() : super(ActivityInitial()) {
    on<FetchActivities>(_onFetchActivities);
    on<FetchActivity>(_onFetchActivity);
    on<ToggleFavorite>(_onToggleFavorite);
  }
// Fetches the activity list with pagination, search, sorting, and category filters.
  Future<void> _onFetchActivities(
      FetchActivities event, Emitter<ActivityState> emit) async {
    final key = jsonEncode([
      event.page,
      event.limit,
      event.search,
      event.sortOrder,
      event.categoryId
    ]);
    final cached = event.useCache ? ActivityListCache.get(key) : null;
    if (cached != null) {
      _lastList = cached;
      emit(ActivityLoaded(cached));
      return;
    }
    final revision = ActivityListCache.revision;
    if (!event.useCache || _lastList == null) emit(ActivityLoading());
    try {
      final activities = await ApiService.fetchActivities(event.page,
          event.limit, event.search, event.sortOrder, event.categoryId, null);
      if (revision != ActivityListCache.revision) {
        // A favorite or account changed during this request; fetch current data.
        if (!isClosed) add(event);
        return;
      }
      _lastList = activities;
      if (event.useCache) ActivityListCache.put(key, activities, revision);
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
      ActivityListCache.clear();
      emit(ActivityFavouriteLoaded(message));
    } catch (e) {}
  }
}
