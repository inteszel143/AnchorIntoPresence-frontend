import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_event.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_state.dart';
import 'package:mindfully_evolve_app/screens/track/track_model.dart';
import 'package:mindfully_evolve_app/utils/urls.dart';

import '../../../common/local_storage.dart';

class TrackBloc extends Bloc<TrackEvent, TrackState> {
  TrackBloc() : super(TrackInitialState()) {
    on<TrackDataFetchEvent>(_onTrackDataFetchEvent);
  }
  Future<void> _onTrackDataFetchEvent(
    TrackDataFetchEvent event,
    Emitter<TrackState> emit,
  ) async {
    emit(TrackLoadingState());
    try {
      final token = await LocalStorage.getToken() ?? '';

      final response = await http.get(
        Uri.parse(Urls.userTrack),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        UserActivitySummary userActivity =
            UserActivitySummary.fromJson(responseBody);
        emit(TrackLoadedState(userActivity));
      } else {
        emit(TrackErrorState('Failed to load data. Please try again later.'));
      }
    } catch (e) {
      emit(TrackErrorState('An error occurred: $e'));
    }
  }
}
