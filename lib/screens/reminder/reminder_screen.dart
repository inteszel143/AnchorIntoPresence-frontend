import '../../common/widgets/scroll_title_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../common/widgets/button_widget.dart';
import '../../common/widgets/custom_appbar.dart';
import 'get_reminders_screen.dart';
import 'reminder_bloc/reminder_bloc.dart';
import 'reminder_model.dart';

class ReminderScreen extends StatefulWidget {
  final DateTime? initialDate;
  final Set<int>? initialDays;
  final int? initialHour;
  final int? initialMinute;
  final String? reminderId;

  const ReminderScreen(
      {super.key,
      this.initialDate,
      this.initialDays,
      this.initialHour,
      this.initialMinute,
      this.reminderId});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  late final Set<int> _selectedDays;
  late DateTime _time;
  DateTime? _date;
  late bool _repeat;

  bool get _editing => widget.reminderId != null;
  bool get _valid => _repeat ? _selectedDays.isNotEmpty : _date != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _time = DateTime(now.year, now.month, now.day, widget.initialHour ?? 8,
        widget.initialMinute ?? 0);
    _selectedDays = {...?widget.initialDays};
    _date = widget.initialDate;
    _repeat = _selectedDays.isNotEmpty || _date == null;
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initial = _date != null && !_date!.isBefore(today) ? _date! : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime(today.year + 10, 12, 31),
      helpText: 'Choose a reminder date',
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  String _schedule(BuildContext context) {
    final time = TimeOfDay.fromDateTime(_time).format(context);
    if (!_repeat) {
      return _date == null
          ? 'Choose a date for your reminder.'
          : '${DateFormat.yMMMd().format(_date!)} at $time';
    }
    if (_selectedDays.isEmpty) return 'Choose the days that fit your routine.';
    if (_selectedDays.length == 7) return 'Every day at $time';
    final ordered = _selectedDays.toList()..sort();
    return '${ordered.map((day) => _days[day]).join(', ')} at $time';
  }

  void _save(BuildContext context) {
    if (!_valid) return;
    final days = _selectedDays.toList()..sort();
    final data = <String, dynamic>{
      if (_editing) 'id': widget.reminderId,
      'time': TimeZoneUtils.localToUtcTimeString(_time.hour, _time.minute),
      'weekday': _repeat ? days : <int>[],
      'date': _repeat ? '' : _date!.toIso8601String(),
    };
    context.read<ReminderBloc>().add(_editing
        ? UpdateReminder(reminderData: data)
        : SetReminder(reminderData: data));
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ReminderBloc(),
        child: BlocConsumer<ReminderBloc, ReminderState>(
          listener: (context, state) {
            if (state is ReminderFailed) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error)));
            } else if (state is ReminderLoaded) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
              setState(() {
                _selectedDays.clear();
                _date = null;
              });
            } else if (state is ReminderUpdateSuccess) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => GetRemindersScreen()),
                (route) => route.isFirst,
              );
            }
          },
          builder: (context, state) {
            final colors = Theme.of(context).colorScheme;
            final saving = state is ReminderLoading;
            return Scaffold(
              body: ScrollTitlePage(
                title: _editing ? 'Edit Reminder' : 'Set Reminder Time',
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(children: [
                        const CustomAppbar(headingTxt: ''),
                        Expanded(
                            child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 20, bottom: 28),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    _editing
                                        ? 'Edit Reminder'
                                        : 'Set Reminder Time',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(
                                    'Make a little space for yourself each day.',
                                    style: TextStyle(
                                        fontSize: 15,
                                        height: 1.5,
                                        color: colors.onSurfaceVariant)),
                                const SizedBox(height: 28),
                                AbsorbPointer(
                                    absorbing: saving,
                                    child: Column(children: [
                                      _card(context,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(children: [
                                                  Icon(Icons.schedule_rounded,
                                                      color: colors.primary,
                                                      size: 22),
                                                  const SizedBox(width: 10),
                                                  Text('Your time to pause',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                ]),
                                                const SizedBox(height: 12),
                                                SizedBox(
                                                    height: 180,
                                                    child: CupertinoTheme(
                                                      data: CupertinoThemeData(
                                                        brightness:
                                                            colors.brightness,
                                                        textTheme: CupertinoTextThemeData(
                                                            dateTimePickerTextStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        24,
                                                                    color: colors
                                                                        .onSurface)),
                                                      ),
                                                      child:
                                                          CupertinoDatePicker(
                                                        mode:
                                                            CupertinoDatePickerMode
                                                                .time,
                                                        initialDateTime: _time,
                                                        use24hFormat: MediaQuery
                                                            .alwaysUse24HourFormatOf(
                                                                context),
                                                        onDateTimeChanged:
                                                            (value) => setState(
                                                                () => _time =
                                                                    value),
                                                      ),
                                                    )),
                                                Center(
                                                    child: Text(
                                                        'Uses your device’s local time',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: colors
                                                                .onSurfaceVariant))),
                                              ])),
                                      const SizedBox(height: 16),
                                      _card(context,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('When to remind you',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                const SizedBox(height: 16),
                                                SizedBox(
                                                    width: double.infinity,
                                                    child:
                                                        SegmentedButton<bool>(
                                                      segments: const [
                                                        ButtonSegment(
                                                            value: true,
                                                            label:
                                                                Text('Repeat')),
                                                        ButtonSegment(
                                                            value: false,
                                                            label: Text(
                                                                'One time')),
                                                      ],
                                                      selected: {_repeat},
                                                      onSelectionChanged:
                                                          (value) => setState(
                                                              () => _repeat =
                                                                  value.first),
                                                    )),
                                                const SizedBox(height: 18),
                                                if (_repeat) ...[
                                                  Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: [
                                                        for (var day = 0;
                                                            day < 7;
                                                            day++)
                                                          FilterChip(
                                                            label: Text(
                                                                _days[day]),
                                                            selected:
                                                                _selectedDays
                                                                    .contains(
                                                                        day),
                                                            showCheckmark:
                                                                false,
                                                            onSelected:
                                                                (selected) =>
                                                                    setState(
                                                                        () {
                                                              selected
                                                                  ? _selectedDays
                                                                      .add(day)
                                                                  : _selectedDays
                                                                      .remove(
                                                                          day);
                                                            }),
                                                          ),
                                                      ]),
                                                  TextButton(
                                                    onPressed: () =>
                                                        setState(() {
                                                      if (_selectedDays
                                                              .length ==
                                                          7) {
                                                        _selectedDays.clear();
                                                      } else {
                                                        _selectedDays.addAll(
                                                            List.generate(7,
                                                                (day) => day));
                                                      }
                                                    }),
                                                    child: Text(_selectedDays
                                                                .length ==
                                                            7
                                                        ? 'Clear days'
                                                        : 'Select every day'),
                                                  ),
                                                ] else
                                                  OutlinedButton.icon(
                                                    onPressed: _pickDate,
                                                    icon: const Icon(
                                                        Icons
                                                            .calendar_today_outlined,
                                                        size: 18),
                                                    label: Text(_date == null
                                                        ? 'Choose a date'
                                                        : DateFormat.yMMMd()
                                                            .format(_date!)),
                                                  ),
                                              ])),
                                    ])),
                                const SizedBox(height: 20),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.notifications_none_rounded,
                                          size: 20,
                                          color: colors.onSurfaceVariant),
                                      const SizedBox(width: 10),
                                      Expanded(
                                          child: Text(_schedule(context),
                                              style: TextStyle(
                                                  color:
                                                      colors.onSurfaceVariant,
                                                  height: 1.5))),
                                    ]),
                                const SizedBox(height: 24),
                                ButtonWidget(
                                  btnTxt: saving
                                      ? 'Saving…'
                                      : _editing
                                          ? 'Save changes'
                                          : 'Set reminder',
                                  widthFactor: 1,
                                  height: 56,
                                  isActive: _valid && !saving,
                                  onTap: () => _save(context),
                                ),
                              ]),
                        )),
                      ]),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

  Widget _card(BuildContext context, {required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: child,
      );
}
