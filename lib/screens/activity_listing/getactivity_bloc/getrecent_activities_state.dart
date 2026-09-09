import 'package:equatable/equatable.dart';

import '../getactivity_model.dart';

// Base state for activity listing, activity details, and favorite actions.
abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object> get props => [];
}

// Initial state before any activity operation is started.
class ActivityInitial extends ActivityState {}

// Indicates that activity data is being loaded.
class ActivityLoading extends ActivityState {}

// Indicates that the favorite action was successfully processed.
class ActivityFavouriteLoaded extends ActivityState {
  final String message;

  const ActivityFavouriteLoaded(this.message);

  @override
  List<Object> get props => [message];
}

// Contains the successfully loaded list of activities.
class ActivityLoaded extends ActivityState {
  final ActivityResponse activities;

  const ActivityLoaded(this.activities);

  @override
  List<Object> get props => [activities];
}

// Contains the successfully loaded details of a selected activity.
class ActivityLoad extends ActivityState {
  final Activity activity;

  const ActivityLoad(this.activity);

  @override
  List<Object> get props => [activity];
}

// Indicates that an activity operation failed.
class ActivityError extends ActivityState {
  final String message;

  const ActivityError(this.message);

  @override
  List<Object> get props => [message];
}

// Indicates that the favorite status is being updated.
class ActivityFavoriteToggling extends ActivityState {}

// Contains the updated favorite status of the activity.
class ActivityFavoriteToggled extends ActivityState {
  final bool isFavorited;
  final String activityId;

  const ActivityFavoriteToggled(
      {required this.isFavorited, required this.activityId});

  @override
  List<Object> get props => [isFavorited, activityId];
}

// Indicates that updating the favorite status failed.
class ActivityFavoriteError extends ActivityState {
  final String message;

  const ActivityFavoriteError(this.message);

  @override
  List<Object> get props => [message];
}
