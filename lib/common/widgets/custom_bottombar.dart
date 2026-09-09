import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mindfully_evolve_app/utils/fonts.dart';

class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {"icon": "assets/images/home_icon.svg", "label": "Home"},
      {"icon": "assets/images/community_icon.svg", "label": "Community"},
      {"icon": "assets/images/track_icon.svg", "label": "Track"},
      {"icon": "assets/images/setting_icon.svg", "label": "Settings"},
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 86,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
            final isActive = index == selectedIndex;
            final itemColor = isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant;

            return Expanded(
              child: Semantics(
                button: true,
                selected: isActive,
                label: items[index]['label'],
                child: InkWell(
                  onTap: () => onItemTapped(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        items[index]['icon']!,
                        width: 25,
                        height: 25,
                        colorFilter: ColorFilter.mode(
                          itemColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        items[index]['label']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          fontFamily: Fonts.body,
                          color: itemColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 3,
                        width: isActive ? 28 : 0,
                        decoration: BoxDecoration(
                          color: itemColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            }),
          ),
        ),
      ),
    );
  }
}
