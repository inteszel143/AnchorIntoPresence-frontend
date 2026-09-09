import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_service.dart';
import 'comment_event.dart';
import 'comment_state.dart';

// Manages comment loading, posting, liking, deletion, and reply operations.
class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc() : super(CommentInitial()) {
    on<FetchCommentsEvent>(_onFetchComments);
    on<PostCommentEvent>(_onPostComment);
    on<LikeCommentEvent>(_onLikeComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<UpdateParentCommentEvent>(_onUpdateParentComment);
  }
// Fetches all comments associated with the selected post.
  Future<void> _onFetchComments(
      FetchCommentsEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoading());

    try {
      final comments = await ApiService.fetchComments(
        event.postId,
      );
      emit(CommentLoaded(comments: comments));
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(CommentError(message: 'Failed to load comments: ${errorMessage}'));
    }
  }

// Posts a new comment or reply and refreshes the comment list after submission.
  Future<void> _onPostComment(
      PostCommentEvent event, Emitter<CommentState> emit) async {
    emit(CommentPosting());
    try {
      await ApiService.postComment(
          event.postId, event.parentCommentId, event.message);
      emit(CommentPosted());
      add(FetchCommentsEvent(event.postId));
    } catch (e) {
      emit(CommentPostError(e.toString()));
    }
  }

// Updates the like status of a comment and refreshes the comment list.
  Future<void> _onLikeComment(
      LikeCommentEvent event, Emitter<CommentState> emit) async {
    emit(CommentLiking());
    try {
      await ApiService.likeComment(event.postId, event.commentId);
      emit(CommentLiked());
      add(FetchCommentsEvent(event.postId));
    } catch (e) {
      emit(CommentLikeError(e.toString()));
    }
  }

// Deletes the selected comment and refreshes the comment list after successful deletion.
  Future<void> _onDeleteComment(
      DeleteCommentEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoading());

    try {
      final success =
          await ApiService.deleteComment(event.postId, event.commentId);
      if (success) {
        emit(CommentDeleted());
        add(FetchCommentsEvent(event.postId));
      } else {
        emit(CommentError(message: 'Failed to delete post.'));
      }
    } catch (e) {
      emit(CommentError(message: 'Failed to delete post: ${e.toString()}'));
    }
  }

// Stores the selected parent comment to support replying to a specific comment.
  void _onUpdateParentComment(
      UpdateParentCommentEvent event, Emitter<CommentState> emit) {
    String parentCommentId = event.parentCommentId;
    emit(ParentCommentUpdated(parentCommentId: parentCommentId));
  }
}
