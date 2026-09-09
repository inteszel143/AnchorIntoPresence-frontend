import '../user_model.dart';

abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserModel user;
  UserProfileLoaded({required this.user});
}

class UserProfileError extends UserProfileState {
  final String message;
  UserProfileError({required this.message});
}
