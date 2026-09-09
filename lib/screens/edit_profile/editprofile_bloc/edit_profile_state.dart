import 'dart:io';

/// Base state class for edit profile with all fields
class EditProfileState {
  final String name;
  final File? pickedImage;
  final String? imageUrl;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  EditProfileState({
    required this.name,
    this.pickedImage,
    this.imageUrl,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  /// Creates a copy of state with optional updates
  EditProfileState copyWith({
    String? name,
    File? pickedImage,
    String? imageUrl,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return EditProfileState(
      name: name ?? this.name,
      pickedImage: pickedImage ?? this.pickedImage,
      imageUrl: imageUrl ?? this.imageUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Initial state before any action
class EditProfileInitial extends EditProfileState {
  EditProfileInitial() : super(name: '');
}

/// Loading state while updating profile
class EditProfileLoading extends EditProfileState {
  EditProfileLoading(EditProfileState prevState)
      : super(
          name: prevState.name,
          pickedImage: prevState.pickedImage,
          imageUrl: prevState.imageUrl,
          isLoading: true,
        );
}

/// Success state with update confirmation message
class EditProfileSuccess extends EditProfileState {
  final String message;
  EditProfileSuccess({required this.message})
      : super(
          name: '',
          isLoading: false,
          successMessage: message,
        );
}

/// Failure state with error message
class EditProfileFailure extends EditProfileState {
  @override
  final String error;
  EditProfileFailure({required this.error})
      : super(
          name: '',
          isLoading: false,
          error: error,
        );
}
