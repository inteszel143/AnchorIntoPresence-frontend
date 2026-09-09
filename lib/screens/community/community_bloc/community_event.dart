import 'package:equatable/equatable.dart';

// Base event for community post actions.
abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object> get props => [];
}

// Triggers loading of community posts.
class FetchPostsEvent extends CommunityEvent {
  const FetchPostsEvent();
  @override
  List<Object> get props => [];
}

// Triggers a like or unlike action for a post.
class LikePostEvent extends CommunityEvent {
  final String postId;
  const LikePostEvent(this.postId);
}

// Triggers deletion of a selected community post.
class DeletePostEvent extends CommunityEvent {
  final String postId;
  const DeletePostEvent({required this.postId});
}

// Triggers loading of a shared community post.
class FetchCommunityPost extends CommunityEvent {
  final String shareId;

  const FetchCommunityPost({required this.shareId});
}
