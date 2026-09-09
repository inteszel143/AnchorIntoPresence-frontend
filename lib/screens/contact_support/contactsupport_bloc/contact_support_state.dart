import 'package:equatable/equatable.dart';

import '../contact_support_model.dart';

/// Base class for all contact support states
abstract class ContactSupportState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state before any action
class ContactSupportInitial extends ContactSupportState {}

/// Loading state while submitting request
class ContactSupportLoading extends ContactSupportState {}

/// Success state with response data
class ContactSupportSuccess extends ContactSupportState {
  final ContactSupportResponseModel response;

  ContactSupportSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

/// Failure state with error message
class ContactSupportFailure extends ContactSupportState {
  final String error;

  ContactSupportFailure(this.error);

  @override
  List<Object?> get props => [error];
}
