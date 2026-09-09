import 'package:equatable/equatable.dart';

import '../community_model.dart';

// Base state for the post likes loading flow.
abstract class PostLikesState extends Equatable {
  const PostLikesState();

  @override
  List<Object> get props => [];
}

class PostLikesInitial extends PostLikesState {}

// Indicates that post likes are being loaded.
class PostLikesLoading extends PostLikesState {}

// Contains the loaded post likes and pagination status.
class PostLikesLoaded extends PostLikesState {
  final List<PostLike> likes;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const PostLikesLoaded({
    required this.likes,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  PostLikesLoaded copyWith({
    List<PostLike>? likes,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PostLikesLoaded(
      likes: likes ?? this.likes,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [likes, currentPage, hasMore, isLoadingMore];
}

// Indicates that loading post likes failed.
class PostLikesError extends PostLikesState {
  final String message;

  const PostLikesError({required this.message});

  @override
  List<Object> get props => [message];
}
