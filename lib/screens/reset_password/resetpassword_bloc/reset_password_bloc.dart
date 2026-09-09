import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/reset_password/resetpassword_bloc/reset_password_event.dart';
import 'package:mindfully_evolve_app/screens/reset_password/resetpassword_bloc/reset_password_state.dart';

import '../../../utils/api_service.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc() : super(ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  Future<void> _onResetPasswordSubmitted(
      ResetPasswordSubmitted event, Emitter<ResetPasswordState> emit) async {
    if (event.password != event.confirmPassword) {
      emit(ResetPasswordFailure("Passwords do not match"));
      return;
    }

    emit(ResetPasswordLoading());

    try {
      final resetPasswordResponse =
          await ApiService.resetPassword(event.email, event.password);

      if (resetPasswordResponse.status) {
        emit(ResetPasswordSuccess(resetPasswordResponse.message));
      } else {
        emit(ResetPasswordFailure(
            resetPasswordResponse.message ?? 'Failed to reset password'));
      }
    } on SocketException catch (e) {
      emit(ResetPasswordFailure('Please check your internet connection'));
    } catch (e) {
      emit(ResetPasswordFailure("An error occurred: $e"));
    }
  }
}
