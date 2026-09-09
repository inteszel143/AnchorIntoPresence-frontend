// track_state.dart

import '../track_model.dart';

abstract class TrackState {}

class TrackInitialState extends TrackState {}

class TrackLoadingState extends TrackState {}

class TrackLoadedState extends TrackState {
  final UserActivitySummary userActivity;
  TrackLoadedState(this.userActivity);
}

class TrackErrorState extends TrackState {
  final String error;
  TrackErrorState(this.error);
}
