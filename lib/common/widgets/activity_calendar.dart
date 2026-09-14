import 'package:flutter/material.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';

class CalendarGrid extends StatefulWidget {
  final List<dynamic> loginDates;
  final bool large;

  const CalendarGrid({super.key, required this.loginDates, this.large = false});

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
                fontSize: widget.large ? 18 : 16,
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 7 days per week
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 0.85,
            mainAxisExtent: widget.large
                ? (MediaQuery.textScalerOf(context).scale(16) + 24)
                    .clamp(56.0, double.infinity)
                : null,
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
                  fontSize: widget.large ? 16 : null,
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
