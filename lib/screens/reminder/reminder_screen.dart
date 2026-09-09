import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/reminder/reminder_bloc/reminder_bloc.dart';
import 'package:mindfully_evolve_app/screens/reminder/reminder_calender_picker.dart';
import 'package:mindfully_evolve_app/screens/reminder/reminder_model.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';
import 'get_reminders_screen.dart';

class ReminderScreen extends StatelessWidget {
  final DateTime? initialDate;
  final Set<int>? initialDays;
  final int? initialHour;
  final int? initialMinute;
  final String? reminderId;

  ReminderScreen({
    Key? key,
    this.initialDate,
    this.initialDays,
    this.initialHour,
    this.initialMinute,
    this.reminderId,
  }) : super(key: key);

  final Set<int> selectedDays = Set<int>();
  DateTime? selectedDate;
  int selectedHour = 0;
  int selectedMinute = 0;

  String getTimeIn24HrFormat(int hour, int minute) {
    return '$hour:${minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay? get initialTime {
    if (initialHour != null && initialMinute != null) {
      return TimeOfDay(hour: initialHour!, minute: initialMinute!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    selectedHour = initialHour ?? 0;
    selectedMinute = initialMinute ?? 0;

    // Initialize selectedDate and selectedDays with initial values if available
    selectedDate = initialDate;
    if (initialDays != null) {
      selectedDays.addAll(initialDays!);
    }

    final bool isEditMode = initialHour != null ||
        initialMinute != null ||
        (initialDays != null && initialDays!.isNotEmpty);

    return BlocProvider(
      create: (_) => ReminderBloc(),
      child: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state is ReminderLoaded) {
            selectedDate = null;
            selectedHour = 0;
            selectedMinute = 0;
            selectedDays.clear();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ColorCodes.buttoncolor,
                ),
              );
            });
          } else if (state is ReminderFailed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: ColorCodes.buttoncolor,
                ),
              );
            });
          } else if (state is ReminderUpdateSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => GetRemindersScreen()),
                (route) => route.isFirst,
              );
            });
          }

          return Scaffold(
            backgroundColor: ColorCodes.backgroundcolor,
            body: Builder(
              builder: (context) {
                // int hour = initialHour ?? 0, minute = initialMinute ?? 0;
                if (state is ReminderLoading) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: ColorCodes.buttoncolor,
                  ));
                } else {
                  return SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomAppbar(
                            headingTxt: isEditMode
                                ? 'Edit Reminder'
                                : Strings.setReminderTime,
                          ),
                          TimePickerGroup(
                            selectedHour: selectedHour,
                            selectedMinute: selectedMinute,
                            onHourChanged: (hour) {
                              selectedHour = hour;
                              context.read<ReminderBloc>().add(TimeChangedEvent(
                                  hour: hour, minute: selectedMinute));
                            },
                            onMinuteChanged: (minute) {
                              selectedMinute = minute;
                              context.read<ReminderBloc>().add(TimeChangedEvent(
                                  hour: selectedHour, minute: minute));
                            },
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              const int dayCount = 7;
                              const double horizontalPadding = 16.0;
                              const double gap = 6.0;
                              final double totalWidth = constraints.maxWidth;
                              final double chipWidth = (totalWidth -
                                      (horizontalPadding * 2) -
                                      (gap * (dayCount - 1))) /
                                  dayCount;

                              final days = [
                                'Sun',
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat'
                              ];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                child: Row(
                                  children: days.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final day = entry.value;
                                    final isSelected =
                                        selectedDays.contains(index);

                                    return Padding(
                                      padding: EdgeInsets.only(
                                          right:
                                              index < dayCount - 1 ? gap : 0),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (selectedDays.contains(index)) {
                                            selectedDays.remove(index);
                                          } else {
                                            selectedDays.add(index);
                                            selectedDate = null;
                                          }
                                          (context as Element).markNeedsBuild();
                                        },
                                        child: Container(
                                          width: chipWidth,
                                          height: 50,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? ColorCodes.buttoncolor
                                                : ColorCodes
                                                    .whiteNewReplacement,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color:
                                                    ColorCodes.searchboxcolor),
                                          ),
                                          child: Text(
                                            day,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? ColorCodes.whitecolor
                                                  : ColorCodes.blackcolor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: Fonts.body,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.clip,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ColorCodes.whiteNewReplacement,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ReminderCalendarPicker(
                                selectedDate: selectedDate,
                                onDateSelected: (date) {
                                  selectedDate = date;
                                  selectedDays.clear();
                                  (context as Element).markNeedsBuild();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
              child: ElevatedButton(
                onPressed: () {
                  final bool isDateSelected = selectedDate != null;
                  final bool areDaysSelected = selectedDays.isNotEmpty;
                  if (selectedDate == null && selectedDays.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a date or days!'),
                        backgroundColor: ColorCodes.buttoncolor,
                      ),
                    );
                    return;
                  }

                  final reminderData = {
                    'time': TimeZoneUtils.localToUtcTimeString(
                        selectedHour, selectedMinute),
                    'weekday': isDateSelected ? [] : selectedDays.toList(),
                    'date':
                        isDateSelected ? selectedDate?.toIso8601String() : "",
                  };
                  final String finalDate = isDateSelected
                      ? selectedDate!.toIso8601String()
                      : (isEditMode
                          ? (initialDate?.toIso8601String() ?? '')
                          : '');

                  final List<int> finalDays = areDaysSelected
                      ? selectedDays.toList()
                      : (isEditMode ? (initialDays?.toList() ?? []) : []);
                  final updatedReminderData = {
                    'id': reminderId,
                    'time': selectedHour != 0 || selectedMinute != 0
                        ? TimeZoneUtils.localToUtcTimeString(
                            selectedHour, selectedMinute)
                        : TimeZoneUtils.localToUtcTimeString(
                            initialHour ?? 0, initialMinute ?? 0),
                    'weekday': isDateSelected ? [] : finalDays,
                    'date': areDaysSelected ? '' : finalDate,
                  };

                  context.read<ReminderBloc>().add(
                        isEditMode
                            ? UpdateReminder(reminderData: updatedReminderData)
                            : SetReminder(reminderData: reminderData),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorCodes.buttoncolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditMode ? 'Edit Reminder' : Strings.setReminder,
                  style: TextStyle(
                      color: ColorCodes.blackcolor,
                      fontSize: 16,
                      fontFamily: Fonts.body,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TimePickerGroup extends StatelessWidget {
  final int selectedHour;
  final int selectedMinute;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const TimePickerGroup({
    Key? key,
    required this.selectedHour,
    required this.selectedMinute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  }) : super(key: key);

  int get _hour12 {
    final h = selectedHour % 12;
    return h == 0 ? 12 : h;
  }

  bool get _isPM => selectedHour >= 12;

  int _to24Hour(int hour12, bool isPM) {
    if (isPM) return hour12 == 12 ? 12 : hour12 + 12;
    return hour12 == 12 ? 0 : hour12;
  }

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 50;
    const double pickerWidth = 70;

    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: (250 / 2) - (itemHeight / 2),
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: itemHeight,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: ColorCodes.whiteNewReplacement,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: pickerWidth,
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: _hour12 - 1),
                  itemExtent: itemHeight,
                  onSelectedItemChanged: (index) {
                    final newHour12 = index + 1;
                    onHourChanged(_to24Hour(newHour12, _isPM));
                  },
                  children: List.generate(12, (index) {
                    final displayHour = index + 1;
                    return Center(
                      child: Text(
                        '$displayHour',
                        style: TextStyle(
                          color: displayHour == _hour12
                              ? ColorCodes.selectedtimepickertextcolor
                              : ColorCodes.timepickertextcolor,
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          fontFamily: Fonts.body,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Text(
                ":",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: ColorCodes.selectedtimepickertextcolor,
                  fontFamily: Fonts.body,
                ),
              ),
              SizedBox(
                width: pickerWidth,
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedMinute),
                  itemExtent: itemHeight,
                  onSelectedItemChanged: (index) => onMinuteChanged(index),
                  children: List.generate(60, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: index == selectedMinute
                              ? ColorCodes.selectedtimepickertextcolor
                              : ColorCodes.timepickertextcolor,
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          fontFamily: Fonts.body,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(
                width: 60,
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: _isPM ? 1 : 0),
                  itemExtent: itemHeight,
                  onSelectedItemChanged: (index) {
                    onHourChanged(_to24Hour(_hour12, index == 1));
                  },
                  children: ['AM', 'PM'].map((label) {
                    final isSelected = (label == 'PM') == _isPM;
                    return Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? ColorCodes.selectedtimepickertextcolor
                              : ColorCodes.timepickertextcolor,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          fontFamily: Fonts.body,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
