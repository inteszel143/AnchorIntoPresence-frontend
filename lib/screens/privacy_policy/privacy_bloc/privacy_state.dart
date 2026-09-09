abstract class PrivacyState {}

class PrivacyInitial extends PrivacyState {}

class PrivacyLoading extends PrivacyState {}

class PrivacyLoaded extends PrivacyState {
  final String description;

  PrivacyLoaded(this.description);
}

class PrivacyError extends PrivacyState {
  final String errorMessage;

  PrivacyError(this.errorMessage);
}
