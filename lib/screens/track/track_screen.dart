import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/tab_content_page.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';
import 'track_bloc/track_bloc.dart';
import 'track_bloc/track_event.dart';
import 'track_bloc/track_state.dart';
import '../totalmedication/total_meditaion.dart';
import '../totalmedication/totalmeditation_bloc/total_meditation_bloc.dart';
import '../totalmedication/totalmeditation_bloc/total_meditation_event.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => TrackBloc()..add(TrackDataFetchEvent()),
        child: BlocBuilder<TrackBloc, TrackState>(
            builder: (context, state) => TrackOverview(state: state)),
      );
}

class TrackOverview extends StatelessWidget {
  const TrackOverview({super.key, required this.state});
  final TrackState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return TabContentPage(
        title: 'Track',
        subtitle: 'Every moment of presence counts.',
        slivers: [
          if (state is TrackLoadedState)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                  child: _summary(context, state as TrackLoadedState)),
            )
          else
            SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                        child: state is TrackLoadingState
                            ? const CircularProgressIndicator()
                            : Text(
                                state is TrackErrorState
                                    ? (state as TrackErrorState).error
                                    : 'No activity yet',
                                textAlign: TextAlign.center,
                                style: text.bodyLarge?.copyWith(
                                    color: colors.onSurfaceVariant))))),
        ]);
  }

  Widget _summary(BuildContext context, TrackLoadedState state) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final data = state.userActivity.data;
    final parts = data.loggedActivities.totalTime.split(':');
    final minutes = parts.length == 2
        ? (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0)
        : 0;
    final streak = data.loginDates.streak;
    final loginDates = streak.isNotEmpty && streak.first['loginDates'] is List
        ? List<String>.from(streak.first['loginDates'])
        : <String>[];
    final now = DateTime.now();
    final loggedDays = loginDates
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .where((date) =>
            date.year == now.year &&
            date.month == now.month &&
            date.day < now.day)
        .map((date) => date.day)
        .toSet()
        .length;
    final missedDays = (now.day - 1 - loggedDays).clamp(0, now.day - 1);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: colors.primary, borderRadius: BorderRadius.circular(28)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.self_improvement_rounded,
                size: 32, color: colors.onPrimary),
            const SizedBox(height: 20),
            Text('Time for yourself',
                style: text.titleMedium?.copyWith(color: colors.onPrimary)),
            const SizedBox(height: 8),
            Text('$minutes',
                style: text.displayMedium?.copyWith(
                    color: colors.onPrimary, fontWeight: FontWeight.w600)),
            Text('total minutes of practice',
                style: text.bodyLarge?.copyWith(color: colors.onPrimary)),
            const SizedBox(height: 20),
            Divider(color: colors.onPrimary.withValues(alpha: .2)),
            TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.centerLeft),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BlocProvider(
                            create: (_) => TotalMeditationBloc()
                              ..add(TotalMeditationFetchDataEvent()),
                            child: TotalMeditationScreen()))),
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: const Text('View all activities')),
          ])),
      const SizedBox(height: 28),
      Text('Your consistency',
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('A little presence, one day at a time.',
          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
      const SizedBox(height: 16),
      Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CalendarGrid(loginDates: loginDates),
            const SizedBox(height: 16),
            Row(children: [
              Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                      color: colors.primary, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('Days you checked in',
                      style: text.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant)))
            ]),
            const SizedBox(height: 16),
            Divider(color: colors.outlineVariant.withValues(alpha: .4)),
            const SizedBox(height: 8),
            Text('Missed days this month: $missedDays',
                style:
                    text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
          ])),
    ]);
  }
}

class CalendarGrid extends StatefulWidget {
  final List<dynamic> loginDates;

  const CalendarGrid({super.key, required this.loginDates});

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
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
    final colors = Theme.of(context).colorScheme;
    List<DateTime> days = _generateCalendarDays(currentMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Previous month',
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  currentMonth =
                      DateTime(currentMonth.year, currentMonth.month - 1);
                });
              },
            ),
            Expanded(
                child: Text(
              "${_getMonthName(currentMonth.month)} ${currentMonth.year}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: Fonts.body,
                color: colors.onSurface,
              ),
            )),
            IconButton(
              tooltip: 'Next month',
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
            childAspectRatio: 0.85,
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
                color: isLoggedIn ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isLoggedIn
                      ? colors.onPrimary
                      : isCurrentMonth
                          ? colors.onSurface
                          : colors.onSurfaceVariant.withValues(alpha: .45),
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
