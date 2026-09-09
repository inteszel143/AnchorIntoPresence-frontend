import 'package:equatable/equatable.dart';

// Base event for post creation and post type actions.
abstract class PostEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Triggers creation of a new post with the user's selected options.
class CreatePostEvent extends PostEvent {
  final String message;
  final String postType;
  final bool postAnonymously;
  final List<String>? imagePaths;

  CreatePostEvent({
    required this.message,
    required this.postType,
    required this.postAnonymously,
    this.imagePaths,
  });

  @override
  List<Object> get props =>
      [message, postType, postAnonymously, imagePaths ?? []];
}

// Updates the selected post type.
class ChangePostTypeEvent extends PostEvent {
  final int index;

  ChangePostTypeEvent(this.index);
}
