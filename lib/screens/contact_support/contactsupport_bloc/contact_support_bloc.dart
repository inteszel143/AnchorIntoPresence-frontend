import 'dart:async';
import 'dart:io';
import '../contact_support_model.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import 'contact_support_event.dart';
import 'contact_support_state.dart';

/// BLoC for managing contact support requests
class ContactSupportBloc
    extends Bloc<ContactSupportEvent, ContactSupportState> {
  final Future<ContactSupportResponseModel> Function(
      {required String title, required String description}) _submit;

  ContactSupportBloc(
      {Future<ContactSupportResponseModel> Function(
              {required String title, required String description})?
          submit})
      : _submit = submit ?? ApiService.submitSupportRequest,
        super(ContactSupportInitial()) {
    // Register event handlers
    on<SubmitSupportRequest>(_onSubmit);
  }

  /// Handles submission of support requests
  Future<void> _onSubmit(
    SubmitSupportRequest event,
    Emitter<ContactSupportState> emit,
  ) async {
    if (state is ContactSupportLoading) return;
    emit(ContactSupportLoading());
    try {
      // Submit support request to API
      final response = await _submit(
        title: event.title,
        description: event.description,
      ).timeout(const Duration(seconds: 30));
      if (!response.status) {
        emit(ContactSupportFailure(
            'Your message couldn’t be sent. Please try again.'));
        return;
      }
      emit(ContactSupportSuccess(response));
    } on TimeoutException {
      emit(ContactSupportFailure(
          'Sending is taking longer than expected. Please try again in a moment.'));
    } on SocketException {
      // Network connectivity error
      emit(ContactSupportFailure('Please check your internet connection'));
    } catch (e) {
      // Handle any other errors
      emit(ContactSupportFailure(
          'Your message couldn’t be sent. Check your connection and try again.'));
    }
  }
}
