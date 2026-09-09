import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(const SignupFormState()) {
    on<SignupNameChanged>(_onNameChanged);
    on<SignupEmailChanged>(_onEmailChanged);
    on<SignupPasswordChanged>(_onPasswordChanged);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<SocialSignupSubmitted>(_onSocialSignupSubmitted);
  }

  void _onNameChanged(SignupNameChanged event, Emitter<SignupState> emit) {
    if (state is SignupFormState) {
      emit((state as SignupFormState).copyWith(name: event.name));
    }
  }

  void _onEmailChanged(SignupEmailChanged event, Emitter<SignupState> emit) {
    if (state is SignupFormState) {
      emit((state as SignupFormState).copyWith(email: event.email));
    }
  }

  void _onPasswordChanged(
      SignupPasswordChanged event, Emitter<SignupState> emit) {
    if (state is SignupFormState) {
      emit((state as SignupFormState).copyWith(password: event.password));
    }
  }

  Future<void> _onSignupSubmitted(
      SignupSubmitted event, Emitter<SignupState> emit) async {
    String? nameToSend = event.name?.isNotEmpty == true ? event.name : null;
    emit(SignupLoading(
      name: nameToSend,
      email: event.email,
      password: event.password,
    ));

    try {
      final responseData = await ApiService.signup(
        name: nameToSend,
        email: event.email,
        password: event.password,
      );
      if (responseData.status == true) {
        emit(SignupSuccess(
          name: nameToSend,
          email: event.email,
          password: event.password,
        ));
      } else {
        emit(SignupFailure(
          error: responseData.message.isNotEmpty
              ? responseData.message
              : 'Login failed',
          name: event.name,
          email: event.email,
          password: event.password,
        ));
      }
    } on SocketException catch (e) {
      emit(SignupFailure(
        error: 'Please check your internet connection',
        name: event.name,
        email: event.email,
        password: event.password,
      ));
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(SignupFailure(
        error: errorMessage,
        name: event.name,
        email: event.email,
        password: event.password,
      ));
    }
  }

  Future<void> _onSocialSignupSubmitted(
    SocialSignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading(
      name: event.name,
      email: event.email,
      password: '',
    ));

    try {
      final response = await ApiService.socialSignup(
        name: cleanString(event.name),
        email: cleanString(event.email),
        socialId: event.socialId,
        loginMedium: event.loginMedium,
      );

      if (response.status == true) {
        emit(SignupSuccess(
          name: event.name,
          email: event.email,
          password: '',
        ));
      } else {
        emit(SignupFailure(
          error: response.message.isNotEmpty
              ? response.message
              : 'Social signup failed',
          name: event.name,
          email: event.email,
          password: '',
        ));
      }
    } on SocketException {
      emit(SignupFailure(
        error: 'Please check your internet connection',
        name: event.name,
        email: event.email,
        password: '',
      ));
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(SignupFailure(
        error: errorMessage,
        name: event.name,
        email: event.email,
        password: '',
      ));
    }
  }
}

String cleanString(String string) {
  return string.replaceAll(' ', '');
}
