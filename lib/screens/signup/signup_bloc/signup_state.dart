import 'package:equatable/equatable.dart';

abstract class SignupState extends Equatable {
  final String? name;
  final String email;
  final String password;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String? errorMessage;
  const SignupState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props =>
      [name, email, password, isSubmitting, isSuccess, isFailure, errorMessage];
}

class SignupFormState extends SignupState {
  const SignupFormState({
    super.name,
    super.email,
    super.password,
  }) : super(
    isSubmitting: false,
    isSuccess: false,
    isFailure: false,
  );

  SignupFormState copyWith({
    String? name,
    String? email,
    String? password,
  }) {
    return SignupFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class SignupLoading extends SignupState {
  const SignupLoading({
    super.name = null,
    required super.email,
    required super.password,
  }) : super(
    isSubmitting: true,
    isSuccess: false,
    isFailure: false,
  );
}

class SignupSuccess extends SignupState {
  const SignupSuccess({
    super.name = null,
    required super.email,
    required super.password,
  }) : super(
    isSubmitting: false,
    isSuccess: true,
    isFailure: false,
  );
}

class SignupFailure extends SignupState {
  final String error;

  const SignupFailure({
    required this.error,
    super.name = null,
    required super.email,
    required super.password,
  }) : super(
    isSubmitting: false,
    isSuccess: false,
    isFailure: true,
    errorMessage: error,
  );

  @override
  List<Object?> get props =>
      super.props..add(error);
}
