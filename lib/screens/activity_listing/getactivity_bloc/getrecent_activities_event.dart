import 'package:equatable/equatable.dart';

// Base event for activity listing, detail, and favorite actions.
abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object> get props => [];
}

// Requests the activity list with pagination, search, sorting, and category filtering.
class FetchActivities extends ActivityEvent {
  final bool useCache;
  final int page;
  final int limit;
  final String search;
  final String sortOrder;
  String? categoryId;

  FetchActivities(
      {this.useCache = false,
      this.page = 1,
      this.limit = 10,
      this.search = '',
      this.sortOrder = '',
      this.categoryId});

  @override
  List<Object> get props => [page, limit, search, sortOrder, useCache];
}

// Requests details for a specific activity.
class FetchActivity extends ActivityEvent {
  String? activityId;

  FetchActivity({this.activityId});

  @override
  List<Object> get props => [];
}

// Triggers an update to the favorite status of an activity.
class ToggleFavorite extends ActivityEvent {
  final String activityId;

  const ToggleFavorite({required this.activityId});

  @override
  List<Object> get props => [activityId];
}
