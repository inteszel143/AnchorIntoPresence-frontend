import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_service.dart';
import 'feeling_categories_event.dart';
import 'feeling_categories_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<SelectCategory>(_onSelectCategory);
  }

  Future<void> _onSelectCategory(
      SelectCategory event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final responseData = await ApiService.selectCategory(event.mood);
      emit(CategorySuccess());
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(CategoryFailure(errorMessage));
    }
  }
}
