import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import '../faq_model.dart';
import 'faq_event.dart';
import 'faq_state.dart';

class FaqBloc extends Bloc<FaqEvent, FaqState> {
  final Future<Map<String, dynamic>> Function(int, int, String) _fetch;
  FaqBloc({Future<Map<String, dynamic>> Function(int, int, String)? fetch})
      : _fetch = fetch ?? ApiService.fetchFAQ, super(FaqInitial()) {
    on<FetchFaqs>(_onFetchFaqs);
  }

  int _requestId = 0;

  Future<void> _onFetchFaqs(
    FetchFaqs event,
    Emitter<FaqState> emit,
  ) async {
    final int currentRequestId = ++_requestId;

    emit(FaqLoading());

    try {
      final jsonData = await _fetch(
        event.page,
        event.limit,
        event.searchQuery,
      ).timeout(const Duration(seconds: 20));

      // Ignore an old response if a newer search has already started.
      if (isClosed || currentRequestId != _requestId) {
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
      if (isClosed || currentRequestId != _requestId) {
        return;
      }

      emit(
        const FaqError(
          'Please check your internet connection',
        ),
      );
    } catch (e) {
      if (isClosed || currentRequestId != _requestId) {
        return;
      }

      emit(
        FaqError(
          'Questions couldn’t load. Please try again.',
        ),
      );
    }
  }
}
