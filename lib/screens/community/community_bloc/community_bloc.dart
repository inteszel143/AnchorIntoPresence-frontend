import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import 'community_event.dart';
import 'community_state.dart';

// Manages community post loading, sharing, likes, and deletion.
class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  CommunityBloc() : super(CommunityInitial()) {
    on<FetchPostsEvent>(_onFetchPosts);
    on<FetchCommunityPost>(_onFetchPost);
    on<LikePostEvent>(_onLikePost);
    on<DeletePostEvent>(_onDeletePost);
  }
  // Fetches the community posts available to the user.
  Future<void> _onFetchPosts(
      FetchPostsEvent event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());

    try {
      final posts = await ApiService.fetchPosts();
      emit(CommunityLoaded(posts: posts));
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(CommunityError(message: errorMessage));
    }
  }

// Fetches a specific community post using its share ID.
  Future<void> _onFetchPost(
      FetchCommunityPost event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());

    try {
      final post = await ApiService.fetchCommunityPost(event.shareId);
      emit(SharedCommunityLoaded(post: post));
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(CommunityError(message: errorMessage));
    }
  }

// Updates the post like status and synchronizes the change with the backend.
  Future<void> _onLikePost(
      LikePostEvent event, Emitter<CommunityState> emit) async {
    if (state is CommunityLoaded) {
      final currentState = state as CommunityLoaded;

      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(
            liked: !post.liked,
            likesCount: post.liked ? post.likesCount - 1 : post.likesCount + 1,
          );
        }
        return post;
      }).toList();

      emit(CommunityLoaded(posts: updatedPosts));

      try {
        await ApiService.likePost(event.postId);
      } catch (e) {
        emit(currentState);
        emit(CommunityError(message: 'Failed to like post'));
      }
    }
  }

// Deletes the selected community post and refreshes the post list.
  Future<void> _onDeletePost(
      DeletePostEvent event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());

    try {
      final success = await ApiService.deletePost(event.postId);
      if (success) {
        add(FetchPostsEvent());
        emit(PostDeleted());
        Future.delayed(Duration(milliseconds: 200), () {});
      } else {
        emit(CommunityError(message: 'Failed to delete post.'));
      }
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(CommunityError(message: 'Failed to delete post: $errorMessage'));
    }
  }
}
