import 'package:equatable/equatable.dart';

abstract class TotalMeditationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TotalMeditationFetchDataEvent extends TotalMeditationEvent {}
