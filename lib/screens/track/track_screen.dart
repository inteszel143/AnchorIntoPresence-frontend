import 'package:flutter/material.dart';
import '../../common/widgets/activity_calendar.dart';
export '../../common/widgets/activity_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/app_scaffold.dart';
import '../../common/widgets/scroll_title_page.dart';
import 'track_bloc/track_bloc.dart';
import 'track_bloc/track_event.dart';
import 'track_bloc/track_state.dart';
import 'track_loading.dart';
import 'activity_log_updates.dart';
import 'your_week_card.dart';
import '../totalmedication/total_meditaion.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key, this.isActive = true, this.createBloc});
  final bool isActive;
  final TrackBloc Function()? createBloc;

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  late final TrackBloc _bloc;
  int? _requestedRevision;
  DateTime? _requestedDay;

  @override
  void initState() {
    super.initState();
    _bloc = widget.createBloc?.call() ?? TrackBloc();
    activityLogRevision.addListener(_refreshIfNeeded);
    _refreshIfNeeded();
  }

  void _refreshIfNeeded() {
    if (!widget.isActive) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final unchanged = _requestedRevision == activityLogRevision.value &&
        _requestedDay == today;
    // Preserve both loaded content and an in-flight request on tab returns.
    if (unchanged && _bloc.state is! TrackErrorState) return;
    _refresh();
  }

  void _refresh() {
    if (!widget.isActive) return;
    final now = DateTime.now();
    _requestedRevision = activityLogRevision.value;
    _requestedDay = DateTime(now.year, now.month, now.day);
    _bloc.add(TrackDataFetchEvent());
  }

  @override
  void didUpdateWidget(covariant TrackScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _refreshIfNeeded();
  }

  @override
  void dispose() {
    activityLogRevision.removeListener(_refreshIfNeeded);
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _bloc,
        child: BlocBuilder<TrackBloc, TrackState>(
            builder: (context, state) =>
                TrackOverview(state: state, onRefresh: _refresh)),
      );
}

class TrackOverview extends StatelessWidget {
  const TrackOverview({super.key, required this.state, this.onRefresh});
  final TrackState state;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AppScaffold(
      body: ScrollTitlePage(
        title: 'Track',
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(children: [
                  const SizedBox(width: 48, height: 48),
                  Expanded(
                      child: Text(
                    'Track',
                    textAlign: TextAlign.center,
                    style:
                        text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  )),
                  IconButton.filledTonal(
                    tooltip: 'Refresh progress',
                    onPressed:
                        state is TrackLoadingState || state is TrackInitialState
                            ? null
                            : onRefresh,
                    icon: const Icon(Icons.refresh_rounded),
                    constraints:
                        const BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                ]),
              ),
              Expanded(
                  child: CustomScrollView(slivers: [
                if (state is TrackLoadedState)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                        child: _summary(context, state as TrackLoadedState)),
                  )
                else if (state is TrackLoadingState ||
                    state is TrackInitialState)
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(child: TrackLoadingSkeleton()),
                  )
                else
                  SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                              child: Text(
                                  state is TrackErrorState
                                      ? (state as TrackErrorState).error
                                      : 'No activity yet',
                                  textAlign: TextAlign.center,
                                  style: text.bodyLarge?.copyWith(
                                      color: colors.onSurfaceVariant))))),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ])),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _summary(BuildContext context, TrackLoadedState state) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final data = state.userActivity.data;
    final parts = data.loggedActivities.totalTime.split(':');
    final minutes = parts.length == 2 ? int.tryParse(parts[0]) ?? 0 : 0;
    final seconds = parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0;
    final showSeconds = minutes == 0 && seconds > 0;
    // Older servers can still supply recent completions until upgraded.
    final practiceDates = data.practiceDates ??
        data.completedActivities
            .map((activity) => activity.completedAt)
            .whereType<DateTime>()
            .toList();
    final loginDates = practiceDates
        .map((date) {
          final local = date.toLocal();
          return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
        })
        .toSet()
        .toList();
    final now = DateTime.now();
    final completedDaysThisMonth = practiceDates
        .map((date) => date.toLocal())
        .where((date) =>
            date.year == now.year &&
            date.month == now.month &&
            !DateTime(date.year, date.month, date.day)
                .isAfter(DateTime(now.year, now.month, now.day)))
        .map((date) => date.day)
        .toSet()
        .length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 8, 12, 20),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text('Your practice',
                    style: text.titleMedium?.copyWith(
                        color: colors.onPrimary, fontWeight: FontWeight.w600))),
            IconButton(
              tooltip: 'View all activities',
              style: IconButton.styleFrom(foregroundColor: colors.onPrimary),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TotalMeditationScreen())),
              icon: const Icon(Icons.arrow_outward_rounded, size: 22),
            ),
          ]),
          const SizedBox(height: 8),
          LayoutBuilder(builder: (context, constraints) {
            Widget metric(
                    {required String value,
                    required String unit,
                    required String label,
                    Key? valueKey}) =>
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(value,
                            key: valueKey,
                            style: text.headlineMedium?.copyWith(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.w600)),
                        Text(unit,
                            style: text.bodyMedium
                                ?.copyWith(color: colors.onPrimary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(label,
                        style:
                            text.bodySmall?.copyWith(color: colors.onPrimary)),
                  ],
                );
            final listening = metric(
                value: '${showSeconds ? seconds : minutes}',
                valueKey: const ValueKey('practice-minutes'),
                unit: showSeconds ? 'sec' : 'min',
                label: 'Listening today');
            final completed = metric(
                value: '$completedDaysThisMonth',
                unit: completedDaysThisMonth == 1 ? 'day' : 'days',
                label: 'Completed this month');
            if (constraints.maxWidth < 280 ||
                MediaQuery.textScalerOf(context).scale(14) > 21) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [listening, const SizedBox(height: 16), completed]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: listening),
              const SizedBox(width: 20),
              Expanded(child: completed),
            ]);
          }),
        ]),
      ),
      const SizedBox(height: 24),
      Text('Your week',
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Your meditation activity at a glance.',
          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
      const SizedBox(height: 16),
      YourWeekCard(key: ObjectKey(data)),
      const SizedBox(height: 24),
      Text('Your consistency',
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('See how your practice unfolds over time.',
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
                  child: Text('Days you completed a meditation',
                      style: text.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant)))
            ]),
            const SizedBox(height: 16),
            Divider(color: colors.outlineVariant.withValues(alpha: .4)),
            const SizedBox(height: 8),
            Text(
                '$completedDaysThisMonth ${completedDaysThisMonth == 1 ? 'day' : 'days'} with a completed meditation this month',
                style:
                    text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
          ])),
      const SizedBox(height: 20),
      Text('Completed practices',
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Your most recently completed meditations.',
          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: data.completedActivities.isEmpty
            ? Text(
                'Your completed practices will appear here after you mark a meditation as complete.',
                style:
                    text.bodyMedium?.copyWith(color: colors.onSurfaceVariant))
            : Column(children: [
                for (var index = 0;
                    index < data.completedActivities.length;
                    index++) ...[
                  if (index > 0) const Divider(height: 28),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.check_circle_rounded,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF81C784)
                            : const Color(0xFF2E7D32),
                        size: 22,
                        semanticLabel: 'Completed'),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(data.completedActivities[index].name,
                              style: text.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                              [
                                if (data.completedActivities[index]
                                        .completedAt !=
                                    null)
                                  MaterialLocalizations.of(context)
                                      .formatMediumDate(data
                                          .completedActivities[index]
                                          .completedAt!
                                          .toLocal()),
                                if (data.completedActivities[index].duration
                                    .isNotEmpty)
                                  'Duration: ${data.completedActivities[index].duration}',
                              ].join(' · '),
                              style: text.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant)),
                        ])),
                  ]),
                ],
              ]),
      ),
    ]);
  }
}
