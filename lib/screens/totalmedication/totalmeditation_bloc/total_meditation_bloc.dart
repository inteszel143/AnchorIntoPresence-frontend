import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/totalmedication/totalmeditation_bloc/total_meditation_event.dart';
import 'package:mindfully_evolve_app/screens/totalmedication/totalmeditation_bloc/total_meditation_state.dart';

import '../../../utils/api_service.dart';

class TotalMeditationBloc
    extends Bloc<TotalMeditationEvent, TotalMeditationState> {
  TotalMeditationBloc() : super(TotalMeditationInitialState()) {
    on<TotalMeditationFetchDataEvent>(_onFetchData);
  }

  Future<void> _onFetchData(TotalMeditationFetchDataEvent event,
      Emitter<TotalMeditationState> emit) async {
    emit(TotalMeditationLoadingState());
    try {
      final responseData = await ApiService.fetchTotalMeditationData();
      emit(TotalMeditationLoadedState(responseData));
    } on SocketException {
      emit(TotalMeditationErrorState('Please check your internet connection'));
    } catch (e) {
      emit(TotalMeditationErrorState('Error occurred: $e'));
    }
  }
}
