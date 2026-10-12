import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_event.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_state.dart';
import 'package:mindfully_evolve_app/screens/track/track_model.dart';
import 'package:mindfully_evolve_app/utils/urls.dart';

import '../../../common/local_storage.dart';

class TrackBloc extends Bloc<TrackEvent, TrackState> {
  TrackBloc({http.Client? client}) : _client = client, super(TrackInitialState()) {
    on<TrackDataFetchEvent>(_onTrackDataFetchEvent);
  }
  final http.Client? _client;
  int _request = 0;

  Future<void> _onTrackDataFetchEvent(
    TrackDataFetchEvent event,
    Emitter<TrackState> emit,
  ) async {
    final request = ++_request;
    emit(TrackLoadingState());
    try {
      final token = await LocalStorage.getToken() ?? '';

      final response = await (_client?.get ?? http.get)(
        Uri.parse(Urls.userTrack),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      if (isClosed || request != _request) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        UserActivitySummary userActivity =
            UserActivitySummary.fromJson(responseBody);
        emit(TrackLoadedState(userActivity));
      } else {
        emit(TrackErrorState('Failed to load data. Please try again later.'));
      }
    } catch (e) {
      if (isClosed || request != _request) return;
      emit(TrackErrorState('An error occurred: $e'));
    }
  }
}
