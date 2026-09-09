import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/privacy_policy/privacy_bloc/privacy_event.dart';
import 'package:mindfully_evolve_app/screens/privacy_policy/privacy_bloc/privacy_state.dart';

import '../../../utils/api_service.dart';

class PrivacyBloc extends Bloc<PrivacyEvent, PrivacyState> {
  PrivacyBloc() : super(PrivacyInitial()) {
    on<FetchPrivacyPolicyEvent>((event, emit) async {
      emit(PrivacyLoading());

      try {
        final description = await ApiService.fetchPrivacyPolicy();

        emit(PrivacyLoaded(description));
      } catch (e) {
        emit(PrivacyError("An error occurred while fetching the data: $e"));
      }
    });
  }
}
