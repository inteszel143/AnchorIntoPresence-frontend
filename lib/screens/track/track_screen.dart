import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_bloc.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_event.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_state.dart';
import 'package:mindfully_evolve_app/utils/image_constants.dart';

import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';
import '../totalmedication/total_meditaion.dart';
import '../totalmedication/totalmeditation_bloc/total_meditation_bloc.dart';
import '../totalmedication/totalmeditation_bloc/total_meditation_event.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    initialIndex: 0,
                  )),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocProvider(
                create: (context) => TrackBloc()..add(TrackDataFetchEvent()),
                child: BlocBuilder<TrackBloc, TrackState>(
                  builder: (context, state) {
                    if (state is TrackLoadingState) {
                      return Stack(
                        children: [
                          Container(
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    }
                    if (state is TrackErrorState) {
                      return Center(
                        child: Text(state.error,
                            style: TextStyle(color: Colors.red)),
                      );
                    }

                    if (state is TrackLoadedState) {
                      final habits = <dynamic>[];
                      final totalTime =
                          state.userActivity.data.loggedActivities.totalTime;
                      final thumbnails =
                          state.userActivity.data.loggedActivities.thumbnails;
                      final streakData =
                          state.userActivity.data.loginDates.streak;
                      final loginDates = (streakData.isNotEmpty &&
                              streakData[0]['loginDates'] != null)
                          ? List<String>.from(
                              streakData[0]['loginDates'] as List<dynamic>)
                          : [];
                      // After you already have loginDates defined, add this:

                      final now = DateTime.now();

// Count days from start of month up to today (excluding today)
                      int totalDaysSoFar =
                          now.day - 1; // days before today in current month

// Count how many of those days are in loginDates
                      int loggedDaysThisMonth = loginDates.where((dateStr) {
                        try {
                          final date = DateTime.parse(dateStr);
                          return date.year == now.year &&
                              date.month == now.month &&
                              date.day < now.day; // only past days, not today
                        } catch (_) {
                          return false;
                        }
                      }).length;

                      int missedDays = totalDaysSoFar - loggedDaysThisMonth;

                      int minutes = 0;
                      int hours = 0;
                      try {
                        final timeParts = totalTime.split(":");
                        if (timeParts.length == 2) {
                          minutes = int.parse(timeParts[0]) * 60 +
                              int.parse(timeParts[1]);
                          hours = int.parse(timeParts[0]);
                        }
                      } catch (e) {
                        minutes = 0;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              Strings.summary,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                                letterSpacing: Fonts.headingLetterSpacing,
                                fontFamily: Fonts.heading,
                                color: ColorCodes.mainheadingcolor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ColorCodes.whiteNewReplacement,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      ImageConstants.newBackGroundImage,
                                      width: 100,
                                      height: 85,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Logged Activities',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: Fonts.headingLetterSpacing,
                                              fontFamily: Fonts.heading,
                                              color: ColorCodes.blackcolor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Total minutes: $minutes',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: Fonts.body,
                                              color: ColorCodes.buttoncolor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BlocProvider(
                                                    create: (context) =>
                                                        TotalMeditationBloc()
                                                          ..add(
                                                              TotalMeditationFetchDataEvent()),
                                                    child:
                                                        TotalMeditationScreen(),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: const [
                                                Text(
                                                  'View all activities',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: Fonts.body,
                                                    color:
                                                        ColorCodes.buttoncolor,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 20,
                                                  color: ColorCodes.buttoncolor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Consistency Streak
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ColorCodes.whiteNewReplacement,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Consistency Streak",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: Fonts.headingLetterSpacing,
                                    fontFamily: Fonts.heading,
                                    color: ColorCodes.mainheadingcolor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: ColorCodes.whiteNewReplacement,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: ColorCodes
                                          .calendergridcontainerbordercolor
                                          .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: CalendarGrid(loginDates: loginDates),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Missed Days: $missedDays ${missedDays == 1 ? 'Day' : 'Days'}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: Fonts.body,
                                    color: ColorCodes.settingDarkContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return const Center(child: Text('No data available'));
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CalendarGrid extends StatefulWidget {
  final List<dynamic> loginDates;

  const CalendarGrid({super.key, required this.loginDates});

  @override
  _CalendarGridState createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> days = _generateCalendarDays(currentMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  currentMonth =
                      DateTime(currentMonth.year, currentMonth.month - 1);
                });
              },
            ),
            Text(
              "${_getMonthName(currentMonth.month)} ${currentMonth.year}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: Fonts.body,
                color: ColorCodes.mainheadingcolor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  currentMonth =
                      DateTime(currentMonth.year, currentMonth.month + 1);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Expanded(child: Center(child: Text(Strings.sun))),
            Expanded(child: Center(child: Text(Strings.mon))),
            Expanded(child: Center(child: Text(Strings.tue))),
            Expanded(child: Center(child: Text(Strings.wed))),
            Expanded(child: Center(child: Text(Strings.thu))),
            Expanded(child: Center(child: Text(Strings.fri))),
            Expanded(child: Center(child: Text(Strings.sat))),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 7 days per week
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.1,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final isCurrentMonth = day.month == currentMonth.month;
            final isLoggedIn = widget.loginDates.contains(
                "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}");

            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isLoggedIn
                    ? ColorCodes.neartodaydatecolor
                    : ColorCodes.transparentcolor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isCurrentMonth
                      ? ColorCodes.mainheadingcolor
                      : ColorCodes.currentmonthtextcolor,
                  fontWeight: FontWeight.w500,
                  fontFamily: Fonts.body,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      Strings.january,
      Strings.february,
      Strings.march,
      Strings.april,
      Strings.may,
      Strings.june,
      Strings.july,
      Strings.august,
      Strings.september,
      Strings.october,
      Strings.november,
      Strings.december,
    ];
    return monthNames[month - 1];
  }

  List<DateTime> _generateCalendarDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    int prependDays = firstDay.weekday % 7;

    final days = List<DateTime>.generate(prependDays, (i) {
      return firstDay.subtract(Duration(days: prependDays - i));
    });

    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    while (days.length % 7 != 0) {
      days.add(days.last.add(const Duration(days: 1)));
    }

    return days;
  }
}
