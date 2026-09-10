import '../user_profile/userprofile_screen.dart';
import '../../common/widgets/app_circle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../utils/urls.dart';
import '../../helping_widgets/user_provider/user_provider.dart';
import '../dashboard/dashboard_bloc/home_bloc.dart';
import '../dashboard/dashboard_bloc/home_state.dart';
import '../setting/setting_screen.dart';
import '../track/track_bloc/track_bloc.dart';
import '../track/track_bloc/track_event.dart';
import '../track/track_bloc/track_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final track = context.read<TrackBloc>();
    if (track.state is TrackInitialState) track.add(TrackDataFetchEvent());
  }

  Set<DateTime> _loginDays(TrackState state) {
    if (state is! TrackLoadedState) return {};
    return {
      for (final entry in state.userActivity.data.loginDates.streak)
        if (entry is Map && entry['loginDates'] is List)
          for (final raw in entry['loginDates'] as List)
            if (DateTime.tryParse(raw.toString()) case final DateTime date)
              DateTime.utc(date.year, date.month, date.day),
    };
  }

  int _longestStreak(Set<DateTime> days) {
    final sorted = days.toList()..sort();
    var longest = 0;
    var current = 0;
    DateTime? previous;
    for (final day in sorted) {
      current = previous != null && day.difference(previous).inDays == 1
          ? current + 1
          : 1;
      if (current > longest) longest = current;
      previous = day;
    }
    return longest;
  }

  String _minutes(TrackState state) {
    if (state is! TrackLoadedState) return '—';
    final parts = state.userActivity.data.loggedActivities.totalTime.split(':');
    if (parts.length != 2) return '—';
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    return hours == null || minutes == null ? '—' : '${hours * 60 + minutes}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final home = context.watch<HomePageBloc>().state;
    final track = context.watch<TrackBloc>().state;
    final profile = home is HomePageLoadedState ? home.profileData : null;
    final editedName = context.watch<UserProvider?>()?.name.trim();
    final names = [editedName, profile?.name.trim()];
    final name = names
        .whereType<String>()
        .where(
          (value) => value.isNotEmpty && !value.contains('@'),
        )
        .firstOrNull;
    final photo = profile?.image;
    final photoUrl = photo == null || photo.isEmpty
        ? null
        : (Uri.tryParse(photo)?.hasScheme == true
            ? photo
            : '${Urls.baseUrlimages}$photo');
    final days = _loginDays(track);
    final loaded = track is TrackLoadedState;
    final monthlyDays = days
        .where((day) => day.year == _month.year && day.month == _month.month)
        .length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Semantics(
                      button: true,
                      label: 'Open profile',
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const UserprofileScreen()),
                        ),
                        child: ClipOval(
                          child: photoUrl == null
                              ? _avatar(colors)
                              : Image.network(photoUrl,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _avatar(colors)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            name == null || name.isEmpty
                                ? 'Your profile'
                                : name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Your mindful journey',
                            style: TextStyle(color: colors.onSurfaceVariant)),
                      ],
                    )),
                    AppCircleButton(
                      tooltip: 'Settings',
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SettingScreen())),
                    ),
                  ]),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: .4)),
                    ),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(22)),
                        child: Row(children: [
                          _statIcon(
                              Icons.local_fire_department_outlined, colors),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('Active days')),
                          Text(loaded ? '${days.length}' : '—',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      const SizedBox(height: 8),
                      IntrinsicHeight(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                            _stat('This month', loaded ? '$monthlyDays' : '—',
                                Icons.calendar_today_outlined, colors),
                            const SizedBox(width: 8),
                            _stat('Minutes of awareness', _minutes(track),
                                Icons.schedule_outlined, colors),
                            const SizedBox(width: 8),
                            _stat(
                                'Longest streak',
                                loaded ? '${_longestStreak(days)}' : '—',
                                Icons.workspace_premium_outlined,
                                colors),
                          ])),
                    ]),
                  ),
                  if (track is TrackLoadingState) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(
                        semanticsLabel: 'Loading your progress'),
                  ],
                  if (track is TrackErrorState)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(children: [
                        const Expanded(
                            child: Text(
                                'Your progress is unavailable right now.')),
                        TextButton(
                            onPressed: () => context
                                .read<TrackBloc>()
                                .add(TrackDataFetchEvent()),
                            child: const Text('Retry')),
                      ]),
                    ),
                  const SizedBox(height: 28),
                  Text('Your progress this month',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  _calendar(days, colors),
                  const SizedBox(height: 12),
                  Text(
                      _selectedDay == null
                          ? 'Highlighted dates show days you checked in.'
                          : '${DateFormat.yMMMd().format(_selectedDay!)} · ${days.contains(_selectedDay) ? 'Checked in' : 'No check-in recorded'}',
                      style: TextStyle(
                          color: colors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(ColorScheme colors) => Container(
        width: 52,
        height: 52,
        color: colors.surfaceContainerHighest,
        child: Icon(Icons.person_rounded,
            color: colors.onSurfaceVariant, size: 30),
      );

  Widget _statIcon(IconData icon, ColorScheme colors) => CircleAvatar(
        radius: 17,
        backgroundColor: colors.tertiaryContainer,
        child: Icon(icon, size: 20, color: colors.onTertiaryContainer),
      );

  Widget _stat(String label, String value, IconData icon, ColorScheme colors) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _statIcon(icon, colors),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
            const Spacer(),
            const SizedBox(height: 6),
            Text(value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  void _changeMonth(int delta) => setState(() {
        _month = DateTime(_month.year, _month.month + delta);
        _selectedDay = null;
      });

  Widget _calendar(Set<DateTime> days, ColorScheme colors) {
    final leading = _month.weekday - 1;
    final count = DateTime(_month.year, _month.month + 1, 0).day;
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: Text(DateFormat.yMMMM().format(_month),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(
              tooltip: 'Previous month',
              onPressed: () => _changeMonth(-1),
              icon: const Icon(Icons.chevron_left)),
          IconButton(
              tooltip: 'Next month',
              onPressed: () => _changeMonth(1),
              icon: const Icon(Icons.chevron_right)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          for (final day in ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'])
            Expanded(
                child: Center(
                    child: Text(day,
                        style: TextStyle(
                            fontSize: 12, color: colors.onSurfaceVariant)))),
        ]),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 6),
          itemCount: ((leading + count) / 7).ceil() * 7,
          itemBuilder: (context, index) {
            final number = index - leading + 1;
            if (number < 1 || number > count) return const SizedBox.shrink();
            final date = DateTime.utc(_month.year, _month.month, number);
            final active = days.contains(date);
            final selected = _selectedDay == date;
            return Semantics(
              label:
                  '${DateFormat.yMMMd().format(date)}, ${active ? 'checked in' : 'no check-in'}',
              selected: selected,
              child: InkResponse(
                onTap: () => setState(() => _selectedDay = date),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? colors.primary : colors.surface,
                    border: selected || date == today
                        ? Border.all(color: colors.primary, width: 2)
                        : null,
                  ),
                  child: Text('$number',
                      style: TextStyle(
                          fontSize: 13,
                          color: active ? colors.onPrimary : colors.onSurface,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w400)),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }
}
