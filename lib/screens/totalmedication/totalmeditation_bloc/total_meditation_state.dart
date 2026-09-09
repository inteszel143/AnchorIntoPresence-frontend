import 'package:equatable/equatable.dart';
import 'package:mindfully_evolve_app/screens/totalmedication/total_meditation_model.dart';

abstract class TotalMeditationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TotalMeditationInitialState extends TotalMeditationState {}

class TotalMeditationLoadingState extends TotalMeditationState {}

class TotalMeditationLoadedState extends TotalMeditationState {
  final TotalMeditationDataResponse data;

  TotalMeditationLoadedState(this.data);

  @override
  List<Object?> get props => [data];
}

class TotalMeditationErrorState extends TotalMeditationState {
  final String error;

  TotalMeditationErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
