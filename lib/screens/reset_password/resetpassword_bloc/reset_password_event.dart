abstract class ResetPasswordEvent {}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  final String email;
  final String password;
  final String confirmPassword;

  ResetPasswordSubmitted({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}
