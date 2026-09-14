import 'dart:ui';
import 'package:flutter/material.dart';

/// Frosted bottom navigation with the app's existing destinations.
class AppTabBar extends StatelessWidget {
  const AppTabBar(
      {super.key, required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.groups_rounded, 'Community'),
    (Icons.insights_rounded, 'Track'),
    (Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final selected = Theme.of(context).colorScheme.primary;
    final unselected = Theme.of(context).colorScheme.onSurfaceVariant;
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
                                    Icon(_items[index].$1,
                                        size: 27, color: color),
                                    const SizedBox(height: 5),
                                    Text(_items[index].$2,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 11,
                                            height: 1.25,
                                            fontWeight: active
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: color)),
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
