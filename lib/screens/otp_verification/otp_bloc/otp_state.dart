abstract class OtpVerificationState {}

class OtpVerificationInitial extends OtpVerificationState {}

class OtpVerificationLoading extends OtpVerificationState {}

class OtpVerificationSuccess extends OtpVerificationState {}

class OtpVerificationFailure extends OtpVerificationState {
  final String error;

  OtpVerificationFailure(this.error);
}

class OtpResendSuccess extends OtpVerificationState {
  final String message;

  OtpResendSuccess(this.message);
}

class OtpResendTimerRunning extends OtpVerificationState {
  final int remainingSeconds;

  OtpResendTimerRunning(this.remainingSeconds);
}

class OtpResendTimerCompleted extends OtpVerificationState {}
