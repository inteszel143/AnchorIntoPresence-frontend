import 'package:equatable/equatable.dart';

/// Base class for all contact support events
abstract class ContactSupportEvent extends Equatable {
  const ContactSupportEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when user submits a support request
class SubmitSupportRequest extends ContactSupportEvent {
  final String title;
  final String description;

  const SubmitSupportRequest({
    required this.title,
    required this.description,
  });

  @override
  List<Object> get props => [title, description];
}
