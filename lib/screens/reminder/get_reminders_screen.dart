import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/reminder/reminder_bloc/reminder_bloc.dart';
import 'package:mindfully_evolve_app/screens/reminder/reminder_model.dart';
import 'package:mindfully_evolve_app/screens/reminder/reminder_screen.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';

class GetRemindersScreen extends StatelessWidget {
  const GetRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCodes.backgroundcolor,
      body: SafeArea(
        child: BlocProvider(
          create: (context) {
            final bloc = ReminderBloc();
            Future.microtask(() => bloc.add(FetchReminder()));
            return bloc;
          },
          child: BlocListener<ReminderBloc, ReminderState>(
            listener: (context, state) {
              if (state is ReminderDeleteSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reminder deleted successfully'),
                    backgroundColor: ColorCodes.buttoncolor,
                  ),
                );
                context.read<ReminderBloc>().add(FetchReminder());
              } else if (state is ReminderDeleteFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: ColorCodes.buttoncolor,
                  ),
                );
              } else if (state is ReminderUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: ColorCodes.buttoncolor,
                  ),
                );
                context.read<ReminderBloc>().add(FetchReminder());
              }
            },
            child: BlocBuilder<ReminderBloc, ReminderState>(
              builder: (context, state) {
                if (state is ReminderLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: ColorCodes.buttoncolor,
                  ));
                } else if (state is ReminderFetchSuccess) {
                  final reminders = state.reminders;
                  if (reminders.isEmpty) {
                    // Show message when no reminders
                    return Column(
                      children: [
                        CustomAppbar(headingTxt: Strings.getReminderTime),
                        Expanded(
                          child: Center(
                            child: Text(
                              'No reminders found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      CustomAppbar(headingTxt: Strings.getReminderTime),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: reminders.length,
                          itemBuilder: (context, index) {
                            return ReminderTile(reminders[index]);
                          },
                        ),
                      ),
                    ],
                  );
                } else if (state is ReminderFailed) {
                  return Center(child: Text(state.error));
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ReminderTile extends StatelessWidget {
  final ReminderModel reminder;

  const ReminderTile(this.reminder, {super.key});

  String formatTime12Hour(String? time24) {
    if (time24 == null || time24.isEmpty) return '';
    final local = TimeZoneUtils.utcTimeStringToLocal(time24);
    int hour = local['hour']!;
    final minute = local['minute']!;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $suffix';
  }

  String getFormattedDate(DateTime? dt) {
    final formattedTime = formatTime12Hour(reminder.time);
    if (dt == null) return formattedTime;
    ;

    // Convert from UTC to local time to get the correct date for the user
    final localDate = dt.toLocal();

    return "${_monthName(localDate.month)} ${localDate.day}, ${localDate.year} - $formattedTime";
  }

  Map<String, int>? convertTimeToHourMinute(String? time) {
    if (time == null || time.isEmpty) return null;
    return TimeZoneUtils.utcTimeStringToLocal(time);
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }

  String getFormattedWeekdays(List<int> weekdays) {
    const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return weekdays.map((d) => dayNames[d % 7]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: ColorCodes.whiteNewReplacement,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getFormattedDate(reminder.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    fontFamily: Fonts.body,
                    color: ColorCodes.mainheadingcolor,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Image.asset('assets/images/reminder_edit_icon.png'),
                      onPressed: () {
                        final result = convertTimeToHourMinute(reminder.time);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ReminderScreen(
                            reminderId: reminder.id,
                            initialHour: result?['hour'],
                            initialMinute: result?['minute'],
                            initialDate: reminder.date,
                            initialDays: reminder.weekdays.toSet(),
                          ),
                        ));
                      },
                    ),
                    IconButton(
                      icon:
                          Image.asset('assets/images/reminderdelete_icon.png'),
                      onPressed: () {
                        context
                            .read<ReminderBloc>()
                            .add(DeleteReminder(reminder.id));
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              getFormattedWeekdays(reminder.weekdays),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: Fonts.body,
                color: ColorCodes.descriptioncolor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
