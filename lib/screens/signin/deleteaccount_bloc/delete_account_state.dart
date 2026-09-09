// Account Deletion States
abstract class AccountDeletionState {}

class AccountDeletionInitial extends AccountDeletionState {}

class AccountDeletionLoading extends AccountDeletionState {}

class AccountDeletionSuccess extends AccountDeletionState {
  final String message;

  AccountDeletionSuccess(this.message);
}

class AccountDeletionFailure extends AccountDeletionState {
  final String error;

  AccountDeletionFailure(this.error);
}
