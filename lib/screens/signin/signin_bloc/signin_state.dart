
abstract class SigninState {}

class SigninInitial extends SigninState {}

class SigninLoading extends SigninState {}

class SigninSuccess extends SigninState {
  final String token;
  final String? name;
  final String? image;
  final bool? isFirst;

  SigninSuccess(this.token, this.name, this.image, this.isFirst);
}
class SocialSigninSuccess extends SigninState {
  final String token;
  final String? name;
  final String? image;


   SocialSigninSuccess(this.token, this.name, this.image);
}
class SigninFailure extends SigninState {
  final String errorMessage;

  SigninFailure(this.errorMessage);
}
