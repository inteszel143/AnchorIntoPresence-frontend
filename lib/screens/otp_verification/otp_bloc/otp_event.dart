import 'package:equatable/equatable.dart';

abstract class OtpVerificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class VerifyOtpSubmitted extends OtpVerificationEvent {
  final String email;
  final String otp;


  VerifyOtpSubmitted({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}
class ResendOtp extends OtpVerificationEvent {
  final String email;

  ResendOtp({required this.email});

  @override
  List<Object?> get props => [email];
}

class StartResendOtpTimer extends OtpVerificationEvent {}

class TickResendOtpTimer extends OtpVerificationEvent {
  final int remainingSeconds;

  TickResendOtpTimer(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}
class StopResendOtpTimer extends OtpVerificationEvent {
  @override
  List<Object> get props => [];
}