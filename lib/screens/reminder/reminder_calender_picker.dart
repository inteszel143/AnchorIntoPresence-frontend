import 'package:flutter/material.dart';

import '../../utils/Colors.dart';
import '../../utils/fix_strings.dart';
import '../../utils/fonts.dart';

class ReminderCalendarPicker extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const ReminderCalendarPicker({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<ReminderCalendarPicker> createState() => _ReminderCalendarPickerState();
}

class _ReminderCalendarPickerState extends State<ReminderCalendarPicker> {
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    final base = widget.selectedDate ?? DateTime.now();
    currentMonth = DateTime(base.year, base.month);
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateCalendarDays(currentMonth);
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

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
                fontFamily: Fonts.heading,
                letterSpacing: Fonts.headingLetterSpacing,
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
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.1,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final isCurrentMonth = day.month == currentMonth.month;
            final dayDateOnly = DateTime(day.year, day.month, day.day);
            final isPast = dayDateOnly.isBefore(todayDateOnly);
            final isSelected = widget.selectedDate != null &&
                dayDateOnly.year == widget.selectedDate!.year &&
                dayDateOnly.month == widget.selectedDate!.month &&
                dayDateOnly.day == widget.selectedDate!.day;

            return GestureDetector(
              onTap: (isCurrentMonth && !isPast)
                  ? () => widget.onDateSelected(dayDateOnly)
                  : null,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorCodes.buttoncolor
                      : ColorCodes.transparentcolor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : !isCurrentMonth || isPast
                            ? ColorCodes.currentmonthtextcolor
                            : ColorCodes.mainheadingcolor,
                    fontWeight: FontWeight.w500,
                    fontFamily: Fonts.body,
                  ),
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
