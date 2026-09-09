import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import 'post_likes_event.dart';
import 'post_likes_state.dart';

// Manages loading and pagination of users who liked a post.
class PostLikesBloc extends Bloc<PostLikesEvent, PostLikesState> {
  PostLikesBloc() : super(PostLikesInitial()) {
    on<FetchPostLikesEvent>(_onFetchPostLikes);
  }
// Fetches post likes page by page and preserves previously loaded results.
  Future<void> _onFetchPostLikes(
      FetchPostLikesEvent event, Emitter<PostLikesState> emit) async {
    final currentState = state;
    var existingLikes = const [];

    if (event.page == 1) {
      emit(PostLikesLoading());
    } else if (currentState is PostLikesLoaded) {
      if (currentState.isLoadingMore || !currentState.hasMore) return;
      existingLikes = currentState.likes;
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(PostLikesLoading());
    }

    try {
      final result = await ApiService.fetchPostLikes(event.postId, event.page);

      emit(PostLikesLoaded(
        likes: [...existingLikes, ...result.likes],
        currentPage: result.page,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      if (currentState is PostLikesLoaded && event.page > 1) {
        emit(currentState.copyWith(isLoadingMore: false));
      } else {
        final errorMessage = e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : e.toString();
        emit(PostLikesError(message: errorMessage));
      }
    }
  }
}
