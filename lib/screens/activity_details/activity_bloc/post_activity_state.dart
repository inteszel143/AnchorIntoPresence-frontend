import 'package:equatable/equatable.dart';
import 'package:mindfully_evolve_app/screens/activity_details/activityresponse_model.dart';

// Base state representing the activity submission process.
abstract class PostActivityState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state before any activity submission is started.
class PostActivityInitial extends PostActivityState {}

// Indicates that activity progress is being submitted.
class PostActivitySubmitting extends PostActivityState {}

// Indicates that activity progress was successfully submitted.
class PostActivitySuccess extends PostActivityState {
  final PostActivityResponseModel response;
  final bool isCompleted;

  PostActivitySuccess({required this.response, required this.isCompleted});

  @override
  List<Object?> get props => [response, isCompleted];
}

// Indicates that activity submission failed.
class PostActivityFailure extends PostActivityState {
  final String error;

  PostActivityFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
