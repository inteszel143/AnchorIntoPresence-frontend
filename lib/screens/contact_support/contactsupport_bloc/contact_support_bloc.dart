import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import 'contact_support_event.dart';
import 'contact_support_state.dart';

/// BLoC for managing contact support requests
class ContactSupportBloc
    extends Bloc<ContactSupportEvent, ContactSupportState> {
  ContactSupportBloc() : super(ContactSupportInitial()) {
    // Register event handlers
    on<SubmitSupportRequest>(_onSubmit);
  }

  /// Handles submission of support requests
  Future<void> _onSubmit(
    SubmitSupportRequest event,
    Emitter<ContactSupportState> emit,
  ) async {
    emit(ContactSupportLoading());
    try {
      // Submit support request to API
      final response = await ApiService.submitSupportRequest(
        title: event.title,
        description: event.description,
      );
      emit(ContactSupportSuccess(response));
    } on SocketException {
      // Network connectivity error
      emit(ContactSupportFailure('Please check your internet connection'));
    } catch (e) {
      // Handle any other errors
      emit(ContactSupportFailure("Error: $e"));
    }
  }
}
