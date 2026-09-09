import 'package:equatable/equatable.dart';

import '../community_model.dart';

// Base state for community post operations.
abstract class CommunityState extends Equatable {
  const CommunityState();

  @override
  List<Object> get props => [];
}

class CommunityInitial extends CommunityState {}

// Indicates that community post data is being loaded.
class CommunityLoading extends CommunityState {}

// Contains the successfully loaded community posts.
class CommunityLoaded extends CommunityState {
  final List<Post> posts;

  const CommunityLoaded({required this.posts});

  @override
  List<Object> get props => [posts];
}

// Contains the community post loaded from a shared link.
class SharedCommunityLoaded extends CommunityState {
  final Post post;
  const SharedCommunityLoaded({required this.post});
}

// Indicates that a post like action was completed.
class CommunityPostLiked extends CommunityState {}

// Indicates that a community post operation failed.
class CommunityError extends CommunityState {
  final String message;

  const CommunityError({required this.message});

  @override
  List<Object> get props => [message];
}

// Indicates that a community post was successfully deleted.
class PostDeleted extends CommunityState {}

// Indicates that deleting the community post failed.
class PostDeleteError extends CommunityState {
  final String message;
  const PostDeleteError({required this.message});
}
