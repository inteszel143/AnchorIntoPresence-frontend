import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import 'add_post_event.dart';
import 'add_post_state.dart';

// Manages post creation and post type selection.
class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostInitial()) {
    on<ChangePostTypeEvent>((event, emit) {
      emit(PostTypeChanged(event.index));
    });
    on<CreatePostEvent>(_onCreatePost);
  }
// Creates a new post with the selected content, type, privacy, and optional images.
  Future<void> _onCreatePost(
      CreatePostEvent event, Emitter<PostState> emit) async {
    emit(PostCreating());
    try {
      await ApiService.createPost(
        message: event.message,
        postType: event.postType,
        postAnonymously: event.postAnonymously,
        imagePaths: event.imagePaths,
      );
      emit(PostCreated());
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(PostError(errorMessage));
    }
  }
}
