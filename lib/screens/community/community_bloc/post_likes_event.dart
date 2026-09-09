import 'package:equatable/equatable.dart';

// Base event for post likes operations.
abstract class PostLikesEvent extends Equatable {
  const PostLikesEvent();

  @override
  List<Object> get props => [];
}

// Requests a specific page of users who liked a post.
class FetchPostLikesEvent extends PostLikesEvent {
  final String postId;
  final int page;

  const FetchPostLikesEvent({required this.postId, required this.page});

  @override
  List<Object> get props => [postId, page];
}
