import 'package:flutter/material.dart';
import '../../common/widgets/activity_calendar.dart';
export '../../common/widgets/activity_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/tab_content_page.dart';
import 'track_bloc/track_bloc.dart';
import 'track_bloc/track_event.dart';
import 'track_bloc/track_state.dart';
import '../totalmedication/total_meditaion.dart';

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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
              color: colors.primary, borderRadius: BorderRadius.circular(28)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.self_improvement_rounded,
                  size: 24, color: colors.onPrimary),
              const SizedBox(width: 10),
              Expanded(
                  child: Text('Time for yourself',
                      style:
                          text.titleMedium?.copyWith(color: colors.onPrimary))),
            ]),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('$minutes',
                    style: text.headlineMedium?.copyWith(
                        color: colors.onPrimary, fontWeight: FontWeight.w600)),
                Text('total minutes of practice',
                    style: text.bodyMedium?.copyWith(color: colors.onPrimary)),
              ],
            ),
            TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.centerLeft),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TotalMeditationScreen())),
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: const Text('View all activities')),
          ])),
      const SizedBox(height: 20),
      Text('Your consistency',
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('A little presence, one day at a time.',
          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
      const SizedBox(height: 16),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CalendarGrid(loginDates: loginDates, large: true),
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
