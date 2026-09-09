// Base event for comment and reply actions.
abstract class CommentEvent {}

// Loads comments and replies for a selected post.
class FetchCommentsEvent extends CommentEvent {
  final String postId;
  FetchCommentsEvent(this.postId);
}

// Creates a new comment or reply on a post.
class PostCommentEvent extends CommentEvent {
  final String postId;
  final String parentCommentId;
  final String message;
  PostCommentEvent(this.postId, this.parentCommentId, this.message);
  @override
  List<Object> get props => [postId, parentCommentId, message];
}

// Updates the like status of a comment.
class LikeCommentEvent extends CommentEvent {
  final String postId;
  final String commentId;
  LikeCommentEvent(this.postId, this.commentId);
  @override
  List<Object> get props => [postId, commentId];
}

// Deletes a selected comment from the post.
class DeleteCommentEvent extends CommentEvent {
  final String postId;
  final String commentId;
  DeleteCommentEvent(this.postId, this.commentId);
  @override
  List<Object> get props => [postId, commentId];
}

// Selects a parent comment when the user chooses to reply.
class UpdateParentCommentEvent extends CommentEvent {
  final String parentCommentId;
  UpdateParentCommentEvent(this.parentCommentId);
}
