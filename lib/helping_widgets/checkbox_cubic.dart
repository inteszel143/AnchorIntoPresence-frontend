import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckboxCubit extends Cubit<Set<String>> {
  CheckboxCubit() : super({}) {
    _loadCheckboxState();
  }

  Future<void> _loadCheckboxState() async {
    final prefs = await SharedPreferences.getInstance();
    final completedActivities = prefs.getStringList('completedActivities') ?? [];
    emit(completedActivities.toSet());
  }

  Future<void> toggleCheckbox(String activityId, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final completedActivities = {...state};

    if (value) {
      completedActivities.add(activityId);
    } else {
      completedActivities.remove(activityId);
    }

    prefs.setStringList('completedActivities', completedActivities.toList());
    emit(completedActivities);
  }
}
