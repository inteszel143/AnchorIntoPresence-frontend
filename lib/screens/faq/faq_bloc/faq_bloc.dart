import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import '../faq_model.dart';
import 'faq_event.dart';
import 'faq_state.dart';

class FaqBloc extends Bloc<FaqEvent, FaqState> {
  FaqBloc() : super(FaqInitial()) {
    on<FetchFaqs>(_onFetchFaqs);
  }

  int _requestId = 0;

  Future<void> _onFetchFaqs(
    FetchFaqs event,
    Emitter<FaqState> emit,
  ) async {
    final int currentRequestId = ++_requestId;

    // Only show the full-screen loader for the first request.
    if (state is! FaqLoaded) {
      emit(FaqLoading());
    }

    try {
      final jsonData = await ApiService.fetchFAQ(
        event.page,
        event.limit,
        event.searchQuery,
      );

      // Ignore an old response if a newer search has already started.
      if (currentRequestId != _requestId) {
        return;
      }

      final List<dynamic> data = jsonData['data'] ?? [];

      final List<Faq> faqs = data
          .map(
            (e) => Faq.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();

      emit(
        FaqLoaded(faqs),
      );
    } on SocketException {
      if (currentRequestId != _requestId) {
        return;
      }

      emit(
        const FaqError(
          'Please check your internet connection',
        ),
      );
    } catch (e) {
      if (currentRequestId != _requestId) {
        return;
      }

      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(
        FaqError(
          '$errorMessage}',
        ),
      );
    }
  }
}
