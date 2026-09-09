import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_service.dart';
import 'delete_account_event.dart';
import 'delete_account_state.dart';

class AccountDeletionBloc
    extends Bloc<AccountDeletionEvent, AccountDeletionState> {
  AccountDeletionBloc() : super(AccountDeletionInitial()) {
    on<AccountDeletionRequest>(_deleteAccount);
  }

  Future<void> _deleteAccount(
    AccountDeletionRequest event,
    Emitter<AccountDeletionState> emit,
  ) async {
    emit(AccountDeletionLoading());

    try {
      // Call the API to delete the account
      final response = await ApiService.deleteAccount();

      if (response['status']) {
        // Emit success state if deletion is successful
        emit(AccountDeletionSuccess(response['message']));
      } else {
        // Emit failure state if there is a failure message from the API
        emit(AccountDeletionFailure(response['message']));
      }
    } catch (e) {
      // Emit failure state if there is any error during the API call
      emit(AccountDeletionFailure(
          "An error occurred while deleting the account."));
    }
  }
}
