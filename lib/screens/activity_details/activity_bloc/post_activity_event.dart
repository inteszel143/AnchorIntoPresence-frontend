import 'package:equatable/equatable.dart';

// Base event for activity progress and completion actions.
abstract class PostActivityEvent extends Equatable {
  const PostActivityEvent();

  @override
  List<Object?> get props => [];
}

// Event triggered when activity progress or completion status is submitted.
class MarkActivityComplete extends PostActivityEvent {
  final String activityId;
  final String videoTimestamp;
  final String totalVideoTime;
  final bool isCompleted;

  const MarkActivityComplete({
    required this.activityId,
    required this.videoTimestamp,
    required this.totalVideoTime,
    required this.isCompleted,
  });

  @override
  List<Object?> get props =>
      [activityId, videoTimestamp, totalVideoTime, isCompleted];
}
