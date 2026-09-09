abstract class TermsState {}

class TermsInitial extends TermsState {}

class TermsLoading extends TermsState {}

class TermsLoaded extends TermsState {
  final String description;

  TermsLoaded(this.description);
}

class TermsError extends TermsState {
  final String errorMessage;

  TermsError(this.errorMessage);
}
