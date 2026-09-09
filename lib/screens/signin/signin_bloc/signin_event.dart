abstract class SigninEvent {}

class SigninSubmitted extends SigninEvent {
  final String email;
  final String password;

  SigninSubmitted({required this.email, required this.password});
}

class SocialSigninSubmitted extends SigninEvent {
  final String loginMedium;
  final String email;
  final String socialId;
  final String fcmToken;

  SocialSigninSubmitted({
    required this.loginMedium,
    required this.email,
    required this.socialId,
    required this.fcmToken,
  });
}
