import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import '../../common/widgets/scroll_title_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../common/widgets/app_circle_button.dart';
import '../../common/widgets/custom_appbar.dart';
import 'reminder_bloc/reminder_bloc.dart';
import 'reminder_model.dart';
import 'reminder_screen.dart';

class GetRemindersScreen extends StatefulWidget {
  const GetRemindersScreen({super.key});

  @override
  State<GetRemindersScreen> createState() => _GetRemindersScreenState();
}

class _GetRemindersScreenState extends State<GetRemindersScreen> {
  List<ReminderModel>? _reminders;

  Future<void> _addReminder(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const ReminderScreen(),
    ));
    if (context.mounted) context.read<ReminderBloc>().add(FetchReminder());
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ReminderBloc()..add(FetchReminder()),
        child: BlocConsumer<ReminderBloc, ReminderState>(
          listener: (context, state) {
            if (state is ReminderFetchSuccess) _reminders = state.reminders;
            if (state is ReminderDeleteSuccess) {
              // The bloc already refreshes the list after a successful deletion.
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder deleted')));
            } else if (state is ReminderDeleteFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error)));
            } else if (state is ReminderFailed && _reminders != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Couldn’t refresh your reminders.'),
                action: SnackBarAction(
                    label: 'Retry',
                    onPressed: () =>
                        context.read<ReminderBloc>().add(FetchReminder())),
              ));
            }
          },
          builder: (context, state) {
            final colors = Theme.of(context).colorScheme;
            final busy = state is ReminderLoading ||
                state is ReminderDeleteInProgress ||
                state is ReminderDeleteSuccess;
            final reminders = _reminders;
            return AppScaffold(
              body: ScrollTitlePage(
                title: 'Reminders',
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(children: [
                        CustomAppbar(
                            headingTxt: '',
                            okimage: const Tooltip(
                                message: 'Add reminder',
                                child: Icon(Icons.add_rounded)),
                            onOkTap: () => _addReminder(context)),
                        Expanded(
                            child: CustomScrollView(slivers: [
                          SliverToBoxAdapter(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 24),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Reminders',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Gentle nudges to come back to yourself.',
                                      style: TextStyle(
                                          fontSize: 15,
                                          height: 1.5,
                                          color: colors.onSurfaceVariant)),
                                  if (reminders != null &&
                                      reminders.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    Text(
                                        '${reminders.length} saved ${reminders.length == 1 ? 'reminder' : 'reminders'} · Local time',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: colors.onSurfaceVariant)),
                                  ],
                                  if (busy && reminders != null) ...[
                                    const SizedBox(height: 16),
                                    const LinearProgressIndicator(
                                        semanticsLabel: 'Updating reminders'),
                                  ],
                                ]),
                          )),
                          if (reminders == null && state is ReminderFailed)
                            SliverToBoxAdapter(
                                child: _message(context,
                                    icon: Icons.wifi_off_rounded,
                                    title: 'Your reminders couldn’t load',
                                    description:
                                        'Please try again in a moment.',
                                    action: 'Try again',
                                    onTap: () => context
                                        .read<ReminderBloc>()
                                        .add(FetchReminder()))),
                          if (reminders == null && state is! ReminderFailed)
                            const SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        semanticsLabel: 'Loading reminders'))),
                          if (reminders != null && reminders.isEmpty)
                            SliverToBoxAdapter(
                                child: _message(context,
                                    icon: Icons.notifications_none_rounded,
                                    title: 'Make time for a pause',
                                    description:
                                        'Choose a time that works for you. Your reminders will appear here.',
                                    action: 'Set your first reminder',
                                    onTap: () => _addReminder(context))),
                          if (reminders != null && reminders.isNotEmpty)
                            SliverPadding(
                                padding: const EdgeInsets.only(bottom: 28),
                                sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                  (context, index) => ReminderTile(
                                      reminders[index],
                                      key: ValueKey(reminders[index].id),
                                      enabled: !busy),
                                  childCount: reminders.length,
                                ))),
                        ])),
                      ]),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

  Widget _message(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required String action,
      required VoidCallback onTap}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24)),
      child: Column(children: [
        CircleAvatar(
            radius: 30,
            backgroundColor: colors.surface,
            child: Icon(icon, color: colors.primary, size: 28)),
        const SizedBox(height: 20),
        Text(title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(description,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.6)),
        const SizedBox(height: 24),
        OutlinedButton(onPressed: onTap, child: Text(action)),
      ]),
    );
  }
}

class ReminderTile extends StatelessWidget {
  const ReminderTile(this.reminder, {super.key, this.enabled = true});
  final ReminderModel reminder;
  final bool enabled;
  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final local = reminder.time == null || reminder.time!.isEmpty
        ? null
        : TimeZoneUtils.utcTimeStringToLocal(reminder.time!);
    final time = local == null
        ? 'Time not set'
        : TimeOfDay(hour: local['hour']!, minute: local['minute']!)
            .format(context);
    final weekdays =
        reminder.weekdays.where((day) => day >= 0 && day < 7).toSet();
    final recurring = weekdays.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.notifications_none_rounded,
              size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
                  recurring ? 'REPEATING REMINDER' : 'ONE-TIME REMINDER',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant))),
        ]),
        const SizedBox(height: 6),
        Text(time,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        if (recurring)
          Wrap(spacing: 4, runSpacing: 4, children: [
            for (var day = 0; day < 7; day++)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                    color: weekdays.contains(day)
                        ? colors.primary
                        : colors.surface,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(_days[day],
                    style: TextStyle(
                        fontSize: 11,
                        color: weekdays.contains(day)
                            ? colors.onPrimary
                            : colors.onSurfaceVariant)),
              ),
          ])
        else
          Text(
              reminder.date == null
                  ? 'No date selected'
                  : DateFormat.yMMMMd().format(reminder.date!.toLocal()),
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14)),
        const SizedBox(height: 10),
        Divider(height: 1, color: colors.outlineVariant.withValues(alpha: .45)),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(
              child: Text(
                  recurring
                      ? weekdays.length == 7
                          ? 'Every day'
                          : 'Every week'
                      : 'On your chosen date',
                  style:
                      TextStyle(fontSize: 12, color: colors.onSurfaceVariant))),
          AppCircleButton(
              tooltip: 'Edit reminder',
              icon: const Icon(Icons.edit_outlined),
              onPressed: !enabled
                  ? null
                  : () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ReminderScreen(
                                reminderId: reminder.id,
                                initialHour: local?['hour'],
                                initialMinute: local?['minute'],
                                initialDate: reminder.date?.toLocal(),
                                initialDays: weekdays,
                              )));
                      if (context.mounted) {
                        context.read<ReminderBloc>().add(FetchReminder());
                      }
                    }),
          const SizedBox(width: 8),
          AppCircleButton(
              tooltip: 'Delete reminder',
              icon: Icon(Icons.delete_outline_rounded, color: colors.onSurface),
              onPressed: !enabled
                  ? null
                  : () => context
                      .read<ReminderBloc>()
                      .add(DeleteReminder(reminder.id))),
        ]),
      ]),
    );
  }
}
