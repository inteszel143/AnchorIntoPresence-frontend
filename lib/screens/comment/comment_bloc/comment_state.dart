import '../../comment/comment_model.dart';

// Base state for the comment and reply management flow.
abstract class CommentState {}

class CommentInitial extends CommentState {}

// Indicates that comments are being loaded.
class CommentLoading extends CommentState {}

// Contains the comments and their associated replies.
class CommentLoaded extends CommentState {
  final List<Comment> comments;
  CommentLoaded({required this.comments});
}

// Indicates that loading comments failed.
class CommentError extends CommentState {
  final String message;
  CommentError({required this.message});
}

class CommentPosting extends CommentState {}

// Indicates that a comment or reply was successfully submitted.
class CommentPosted extends CommentState {}

// Indicates that submitting a comment or reply failed.
class CommentPostError extends CommentState {
  final String message;
  CommentPostError(this.message);
  @override
  List<Object> get props => [message];
}

// Indicates that a comment like action is being processed.
class CommentLiking extends CommentState {}

// Indicates that the comment like action was successful.
class CommentLiked extends CommentState {}

// Indicates that updating the comment like status failed.
class CommentLikeError extends CommentState {
  final String message;
  CommentLikeError(this.message);
  @override
  List<Object> get props => [message];
}

// Indicates that the comment was successfully deleted.
class CommentDeleted extends CommentState {}

// Indicates that a parent comment has been selected for a reply.
class ParentCommentUpdated extends CommentState {
  final String parentCommentId;
  ParentCommentUpdated({required this.parentCommentId});
}
