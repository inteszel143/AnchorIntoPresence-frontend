import 'dart:ui';
import 'package:flutter/material.dart';

/// Frosted bottom navigation with the app's existing destinations.
class AppTabBar extends StatelessWidget {
  const AppTabBar(
      {super.key, required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.pentagon_rounded, 'Home'),
    (Icons.library_books_rounded, 'Library'),
    (Icons.groups_rounded, 'Community'),
    (Icons.insights_rounded, 'Track'),
    (Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final selected = Theme.of(context).colorScheme.primary;
    final unselected = (dark ? Colors.grey.shade400 : Colors.grey.shade600)
        .withValues(alpha: 0.8);
    const radius = BorderRadius.vertical(top: Radius.circular(28));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: dark ? .18 : .06),
              blurRadius: 24,
              offset: const Offset(0, -4))
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(_items.length, (index) {
                    final active = index == selectedIndex;
                    final color = active ? selected : unselected;
                    return Expanded(
                      child: Semantics(
                        selected: active,
                        button: true,
                        label: _items[index].$2,
                        child: ExcludeSemantics(
                          child: InkWell(
                            onTap: () => onTap(index),
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (index == 1 || index == 3)
                                      SizedBox.square(
                                        dimension: 27,
                                        child: Center(
                                          child: SizedBox.square(
                                            dimension: index == 1 ? 21 : 23,
                                            child: CustomPaint(
                                              painter: index == 1
                                                  ? _LibraryIconPainter(color)
                                                  : _CalendarCheckIconPainter(
                                                      color),
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Icon(_items[index].$1,
                                          size: 27, color: color),
                                    const SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(_items[index].$2,
                                            maxLines: 1,
                                            softWrap: false,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 11,
                                                height: 1.25,
                                                fontWeight: active
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: color)),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded square library mark, drawn on a 24-unit grid.
class _LibraryIconPainter extends CustomPainter {
  const _LibraryIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 2, 20, 20),
        const Radius.circular(2.5),
      ),
      paint,
    );
    canvas.drawLine(const Offset(6.5, 6.5), const Offset(6.5, 17.5), paint);
    canvas.drawLine(const Offset(11, 6.5), const Offset(11, 17.5), paint);
    canvas.drawLine(const Offset(15, 6.5), const Offset(17.5, 17.5), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LibraryIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Calendar with a completion check, matching the Library's outline style.
class _CalendarCheckIconPainter extends CustomPainter {
  const _CalendarCheckIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(3, 4, 18, 18),
        const Radius.circular(2.5),
      ),
      paint,
    );
    canvas.drawLine(const Offset(8, 2), const Offset(8, 6), paint);
    canvas.drawLine(const Offset(16, 2), const Offset(16, 6), paint);
    canvas.drawLine(const Offset(3, 10), const Offset(21, 10), paint);
    canvas.drawPath(
      Path()
        ..moveTo(8, 16)
        ..lineTo(11, 19)
        ..lineTo(16, 14),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CalendarCheckIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
