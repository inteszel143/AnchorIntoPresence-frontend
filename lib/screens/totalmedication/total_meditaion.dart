import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/totalmedication/total_meditation_model.dart';
import 'package:mindfully_evolve_app/screens/totalmedication/totalmeditation_bloc/total_meditation_bloc.dart';
import 'package:mindfully_evolve_app/screens/totalmedication/totalmeditation_bloc/total_meditation_event.dart';
import 'package:mindfully_evolve_app/screens/totalmedication/totalmeditation_bloc/total_meditation_state.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_bloc.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_event.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_state.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';

class TotalMeditationScreen extends StatelessWidget {
  const TotalMeditationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TotalMeditationBloc>(
          create: (context) =>
              TotalMeditationBloc()..add(TotalMeditationFetchDataEvent()),
        ),
        BlocProvider<TrackBloc>(
          create: (context) => TrackBloc()..add(TrackDataFetchEvent()),
        ),
      ],
      child: Scaffold(
        backgroundColor: ColorCodes.backgroundcolor,
        body: SafeArea(
          child: _TotalMeditationBody(),
        ),
      ),
    );
  }
}

// ── Separate StatelessWidget so BlocBuilder can access both blocs cleanly ────
class _TotalMeditationBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TotalMeditationBloc, TotalMeditationState>(
      builder: (context, meditationState) {
        return BlocBuilder<TrackBloc, TrackState>(
          builder: (context, trackState) {
            // ── Single combined loader ──────────────────────────────────────
            final bool isLoading =
                meditationState is TotalMeditationLoadingState ||
                    trackState is TrackLoadingState;

            if (isLoading) {
              return Center(
                  child: CircularProgressIndicator(
                color: ColorCodes.buttoncolor,
              ));
            }

            // ── Error states ────────────────────────────────────────────────
            if (meditationState is TotalMeditationErrorState) {
              return Center(
                child: Text(meditationState.error,
                    style: const TextStyle(color: Colors.red)),
              );
            }
            if (trackState is TrackErrorState) {
              return Center(
                child: Text(trackState.error,
                    style: const TextStyle(color: Colors.red)),
              );
            }

            // ── Both loaded ─────────────────────────────────────────────────
            if (meditationState is TotalMeditationLoadedState &&
                trackState is TrackLoadedState) {
              // --- loginDates ---
              final streakData = trackState.userActivity.data.loginDates.streak;
              final List<String> loginDates =
                  (streakData.isNotEmpty && streakData[0]['loginDates'] != null)
                      ? List<String>.from(
                          streakData[0]['loginDates'] as List<dynamic>)
                      : <String>[];

              // --- missed days calculation (dynamic) ---
              final now = DateTime.now();
              final int totalDaysSoFar = now.day - 1;
              final int loggedThisMonth = loginDates.where((dateStr) {
                try {
                  final date = DateTime.parse(dateStr);
                  return date.year == now.year &&
                      date.month == now.month &&
                      date.day < now.day;
                } catch (_) {
                  return false;
                }
              }).length;
              final int missedDays = totalDaysSoFar - loggedThisMonth;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppbar(headingTxt: Strings.totalMeditation),

                    // ── Week bars ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorCodes.whiteNewReplacement,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50),
                            _buildDayBars(meditationState.data.data.week),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // ── Consistency streak calendar ────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
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
                                      .withOpacity(0.12),
                                ),
                              ),
                              child: CalendarGrid(loginDates: loginDates),
                            ),
                            const SizedBox(height: 12),
                            // ── Dynamic missed days ──────────────────────
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
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildDayBars(List<Day> weekData) {
    // Rotate Mon–Sun -> Sun–Sat (move last item to front)
    final List<Day> reordered = weekData.isNotEmpty
        ? [weekData.last, ...weekData.sublist(0, weekData.length - 1)]
        : weekData;

    final int maxValue =
        reordered.fold(0, (max, day) => day.value > max ? day.value : max);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(reordered.length, (index) {
        final dayData = reordered[index];
        final double normalizedValue =
            maxValue == 0 ? 0 : dayData.value / maxValue;
        return _buildDayBar(dayData.day, normalizedValue);
      }),
    );
  }

  Widget _buildDayBar(String label, double normalizedValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 120,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: ColorCodes.buildbargreycolor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            heightFactor: normalizedValue,
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                color: ColorCodes.buttoncolor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ── CalendarGrid ─────────────────────────────────────────────────────────────

class CalendarGrid extends StatefulWidget {
  final List<dynamic> loginDates;

  const CalendarGrid({Key? key, required this.loginDates}) : super(key: key);

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
    final List<DateTime> days = _generateCalendarDays(currentMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() {
                currentMonth =
                    DateTime(currentMonth.year, currentMonth.month - 1);
              }),
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
              onPressed: () => setState(() {
                currentMonth =
                    DateTime(currentMonth.year, currentMonth.month + 1);
              }),
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
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.1,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final bool isCurrentMonth = day.month == currentMonth.month;
            final bool isLoggedIn = widget.loginDates.contains(
              "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}",
            );

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
    final int prependDays = firstDay.weekday % 7;

    final days = List<DateTime>.generate(
      prependDays,
      (i) => firstDay.subtract(Duration(days: prependDays - i)),
    );

    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    while (days.length % 7 != 0) {
      days.add(days.last.add(const Duration(days: 1)));
    }

    return days;
  }
}

// ── DonutChartWithLegend & _DonutChartPainter ────────────────────────────────

class DonutChartWithLegend extends StatelessWidget {
  final List<double> percentages;
  final List<Color> colors;
  final List<String> labels;
  final String centerText1;
  final String centerText2;

  const DonutChartWithLegend({
    Key? key,
    required this.percentages,
    required this.colors,
    required this.labels,
    required this.centerText1,
    required this.centerText2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(268.67, 268.67),
                painter: _DonutChartPainter(percentages, colors),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerText1,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        fontFamily: Fonts.body,
                        color: ColorCodes.mainheadingcolor,
                      ),
                    ),
                    Text(
                      centerText2,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: Fonts.body,
                        color: ColorCodes.selecteddatetextcolor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (percentages.length == 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "${labels[0]} - ${(percentages[0] * 100).toStringAsFixed(1)}%",
              style: const TextStyle(
                fontSize: 16,
                fontFamily: Fonts.body,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          Column(
            children: List.generate(labels.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      labels[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: Fonts.body,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${(percentages[index] * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: Fonts.body,
                        fontWeight: FontWeight.w400,
                        color: ColorCodes.selecteddatetextcolor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;

  final double gapRadians = 0.1;
  final double strokeWidth = 60;
  final double blueBulge = 15.0;

  _DonutChartPainter(this.percentages, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double baseRadius = (size.width / 2) - strokeWidth / 2;
    double startAngle = -math.pi / 2;

    final totalPercentage = percentages.fold(0.0, (sum, p) => sum + p);
    final totalGap = gapRadians * percentages.length;
    final totalContent = 2 * math.pi - totalGap;

    final List<double> sweepAngles =
        percentages.map((p) => (p / totalPercentage) * totalContent).toList();

    final blueIndex =
        colors.indexWhere((c) => c == ColorCodes.donutchartpinkcolor);

    for (int i = 0; i < percentages.length; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..isAntiAlias = true
        ..color = colors[i];

      final radius = (i == blueIndex) ? baseRadius + blueBulge : baseRadius;
      final arcRect = Rect.fromCircle(center: center, radius: radius);
      final sliceStart = startAngle + gapRadians / 2;
      final sweep = sweepAngles[i];

      canvas.drawArc(arcRect, sliceStart, sweep, false, paint);

      final midAngle = sliceStart + sweep / 2;
      final labelX = center.dx + radius * math.cos(midAngle);
      final labelY = center.dy + radius * math.sin(midAngle);

      final percentageText = "${(percentages[i] * 100).toStringAsFixed(1)}%";
      final textPainter = TextPainter(
        text: TextSpan(
          text: percentageText,
          style: TextStyle(
            color: colors[i].computeLuminance() > 0.5
                ? ColorCodes.blackcolor
                : ColorCodes.whitecolor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: Fonts.body,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );

      startAngle += sweep + gapRadians;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.percentages != percentages ||
        oldDelegate.colors != colors;
  }
}
