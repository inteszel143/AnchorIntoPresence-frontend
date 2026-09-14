import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets/activity_calendar.dart';
import '../../common/widgets/app_scaffold.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../common/widgets/scroll_title_page.dart';
import '../../utils/string_constants.dart';
import '../track/track_bloc/track_bloc.dart';
import '../track/track_bloc/track_event.dart';
import '../track/track_bloc/track_state.dart';
import 'total_meditation_model.dart';
import 'totalmeditation_bloc/total_meditation_bloc.dart';
import 'totalmeditation_bloc/total_meditation_event.dart';
import 'totalmeditation_bloc/total_meditation_state.dart';

class TotalMeditationScreen extends StatelessWidget {
  const TotalMeditationScreen({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) =>
                  TotalMeditationBloc()..add(TotalMeditationFetchDataEvent())),
          BlocProvider(create: (_) => TrackBloc()..add(TrackDataFetchEvent())),
        ],
        child: BlocBuilder<TotalMeditationBloc, TotalMeditationState>(
          builder: (context, meditationState) =>
              BlocBuilder<TrackBloc, TrackState>(
            builder: (context, trackState) => TotalMeditationOverview(
              meditationState: meditationState,
              trackState: trackState,
              onRetry: () {
                context
                    .read<TotalMeditationBloc>()
                    .add(TotalMeditationFetchDataEvent());
                context.read<TrackBloc>().add(TrackDataFetchEvent());
              },
            ),
          ),
        ),
      );
}

class TotalMeditationOverview extends StatelessWidget {
  const TotalMeditationOverview(
      {super.key,
      required this.meditationState,
      required this.trackState,
      required this.onRetry});
  final TotalMeditationState meditationState;
  final TrackState trackState;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppScaffold(
        body: ScrollTitlePage(
          title: Strings.totalMeditation,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomAppbar(headingTxt: ''),
                ),
                Expanded(
                    child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Strings.totalMeditation,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('Every moment of presence adds up.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                        const SizedBox(height: 24),
                        ..._content(context),
                      ]),
                )),
              ]),
            ),
          ),
        ),
      );

  List<Widget> _content(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final meditation = meditationState;
    final track = trackState;
    if (meditation is TotalMeditationLoadingState ||
        track is TrackLoadingState) {
      return [
        const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()))
      ];
    }
    final error = meditation is TotalMeditationErrorState
        ? meditation.error
        : track is TrackErrorState
            ? track.error
            : null;
    if (error != null) {
      return [
        _card(context, children: [
          Text('Unable to load your activity', style: text.titleLarge),
          const SizedBox(height: 8),
          Text(error,
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ])
      ];
    }
    if (meditation is! TotalMeditationLoadedState ||
        track is! TrackLoadedState) {
      return [
        const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()))
      ];
    }
    final streak = track.userActivity.data.loginDates.streak;
    final dates = streak.isNotEmpty && streak.first['loginDates'] is List
        ? List<String>.from(streak.first['loginDates'])
        : <String>[];
    final now = DateTime.now();
    final loggedDays = dates
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .where((d) =>
            d.year == now.year && d.month == now.month && d.day < now.day)
        .map((d) => d.day)
        .toSet()
        .length;
    final missedDays = (now.day - 1 - loggedDays).clamp(0, now.day - 1);
    return [
      _card(context, children: [
        Text('Your week',
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('A little practice, one day at a time.',
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
        const SizedBox(height: 20),
        _weekChart(context, meditation.data.data.week),
      ]),
      const SizedBox(height: 24),
      Text('Your consistency',
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      _card(context, children: [
        CalendarGrid(loginDates: dates, large: true),
        const SizedBox(height: 16),
        Row(children: [
          Icon(Icons.circle, size: 10, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Days you checked in',
                  style: text.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant))),
        ]),
        const SizedBox(height: 12),
        Divider(color: colors.outlineVariant.withValues(alpha: .4)),
        Text('Missed days this month: $missedDays',
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
      ]),
    ];
  }

  Widget _card(BuildContext context, {required List<Widget> children}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _weekChart(BuildContext context, List<Day> week) {
    final colors = Theme.of(context).colorScheme;
    if (week.isEmpty || week.every((day) => day.value <= 0)) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text('No practice recorded this week yet.',
              style: TextStyle(color: colors.onSurfaceVariant)));
    }
    // Preserve the API's Mon–Sun to Sun–Sat ordering.
    final days = [week.last, ...week.take(week.length - 1)];
    final maxValue =
        days.fold<int>(0, (max, day) => day.value > max ? day.value : max);
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: days
            .map((day) => Expanded(
                  child: Semantics(
                      label: '${day.day}: ${day.value}',
                      child: ExcludeSemantics(
                          child: Column(children: [
                        Container(
                          width: 20,
                          height: 120,
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(8)),
                          child: FractionallySizedBox(
                              heightFactor:
                                  (day.value / maxValue).clamp(0.0, 1.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: BorderRadius.circular(8)))),
                        ),
                        const SizedBox(height: 10),
                        Text(day.day,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant)),
                      ]))),
                ))
            .toList());
  }
}
