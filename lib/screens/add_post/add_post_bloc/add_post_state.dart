import 'package:equatable/equatable.dart';

// Base state for the post creation flow.
abstract class PostState extends Equatable {
  @override
  List<Object> get props => [];
}

class PostInitial extends PostState {}

// Indicates that the post is being created.
class PostCreating extends PostState {}

// Indicates that the post was created successfully.
class PostCreated extends PostState {}

// Indicates that post creation failed.
class PostError extends PostState {
  final String message;
  PostError(this.message);
  @override
  List<Object> get props => [message];
}

// Indicates that the selected post type has changed.
class PostTypeChanged extends PostState {
  final int selectedPostTypeIndex;
  PostTypeChanged(this.selectedPostTypeIndex);
}
