import 'dart:io';

import 'package:bloc/bloc.dart';

import '../../../utils/api_service.dart';
import '../forgot_password_model.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<SubmitForgotPassword>((event, emit) async {
      emit(ForgotPasswordLoading());
      try {
        final responseBody = await ApiService.submitForgotPassword(event.email);
        final model = ForgotPasswordResponseModel.fromJson(responseBody);
        if (model.status) {
          emit(ForgotPasswordSuccess(model.message));
        } else {
          emit(ForgotPasswordFailure(
              responseBody['message'] ?? 'Unknown error'));
        }
      } on SocketException {
        emit(ForgotPasswordFailure('Please check your internet connection'));
      } catch (e) {
        emit(ForgotPasswordFailure('Please check your internet connection'));
      }
    });
  }
}

String cleanEmail(String email) {
  return email.replaceAll(' ', '');
}
