import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

/// BLoC for managing edit profile functionality
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(EditProfileInitial()) {
    // Handle name change event - update name in state
    on<NameChanged>((event, emit) {
      emit(state.copyWith(name: event.name, error: null, successMessage: null));
    });

    // Handle image picked event - store picked image in state
    on<ImagePicked>((event, emit) {
      emit(state.copyWith(
          pickedImage: event.image, error: null, successMessage: null));
    });

    // Handle image URL set event - store image URL in state
    on<ImageUrlSet>((event, emit) {
      emit(state.copyWith(imageUrl: event.imageUrl));
    });

    // Handle profile update submission
    on<UpdateProfile>(_onUpdateProfile);
  }

  /// Handles profile update API call
  Future<void> _onUpdateProfile(
      UpdateProfile event, Emitter<EditProfileState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));

    try {
      // Call API to update profile with name and image
      final model = await ApiService.updateProfile(
        name: event.name,
        image: event.image,
      );
      emit(state.copyWith(
        isLoading: false,
        successMessage: model.message ?? 'Profile updated successfully',
      ));
    } on SocketException catch (e) {
      // Handle network connectivity error
      emit(state.copyWith(
          isLoading: false, error: 'Please check your internet connection'));
    } catch (e) {
      // Handle any other errors
      emit(state.copyWith(isLoading: false, error: 'Something went wrong: $e'));
    }
  }
}
