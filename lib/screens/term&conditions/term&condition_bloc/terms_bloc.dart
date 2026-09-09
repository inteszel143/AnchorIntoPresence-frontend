import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/term&conditions/term&condition_bloc/terms_event.dart';
import 'package:mindfully_evolve_app/screens/term&conditions/term&condition_bloc/terms_state.dart';

import '../../../utils/api_service.dart';

class TermsBloc extends Bloc<TermsEvent, TermsState> {
  TermsBloc() : super(TermsInitial()) {
    on<FetchTermsEvent>((event, emit) async {
      emit(TermsLoading());

      try {
        final description = await ApiService.fetchTerms();

        emit(TermsLoaded(description));
      } catch (e) {
        emit(TermsError("An error occurred while fetching the data: $e"));
      }
    });
  }
}
