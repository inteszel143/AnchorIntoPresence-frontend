import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignupNameChanged extends SignupEvent {
  final String name;

  SignupNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class SignupEmailChanged extends SignupEvent {
  final String email;

  SignupEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class SignupPasswordChanged extends SignupEvent {
  final String password;

  SignupPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class SignupSubmitted extends SignupEvent {
  final String? name;
  final String email;
  final String password;

  SignupSubmitted({
    this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}
class SocialSignupSubmitted extends SignupEvent {
  final String name;
  final String email;
  final String socialId;
  final String loginMedium;

  SocialSignupSubmitted({
    required this.name,
    required this.email,
    required this.socialId,
    required this.loginMedium,
  });
}
