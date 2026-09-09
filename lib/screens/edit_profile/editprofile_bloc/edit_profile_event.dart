import 'dart:io';

/// Base class for all edit profile events
abstract class EditProfileEvent {}

/// Event triggered when user changes their name
class NameChanged extends EditProfileEvent {
  final String name;
  NameChanged(this.name);
}

/// Event triggered when user picks a new profile image
class ImagePicked extends EditProfileEvent {
  final File image;
  ImagePicked(this.image);
}

/// Event triggered to set image URL from existing profile
class ImageUrlSet extends EditProfileEvent {
  final String? imageUrl;
  ImageUrlSet(this.imageUrl);
}

/// Event triggered to submit profile update
class UpdateProfile extends EditProfileEvent {
  final String name;
  final File? image;
  UpdateProfile({required this.name, this.image});
}
