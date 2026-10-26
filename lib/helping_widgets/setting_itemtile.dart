import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/fonts.dart';

class SettingItemTile extends StatelessWidget {
  final String iconPath;
  final String option;
  final String? subtitle;
  final String? badge;
  final bool destructive;
  final bool showToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  const SettingItemTile({
    super.key,
    required this.iconPath,
    required this.option,
    this.subtitle,
    this.badge,
    this.destructive = false,
    this.showToggle = false,
    this.toggleValue,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = colors.onSurface;
    return InkWell(
      onTap: showToggle && onToggle != null && toggleValue != null
          ? () => onToggle!(!toggleValue!)
          : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: 42,
            height: 42,
            child: SvgPicture.asset(iconPath,
                colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(option,
                      style: TextStyle(
                          fontFamily: Fonts.body,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: foreground)),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1B3D2A)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(badge!,
                          style: TextStyle(
                            fontFamily: Fonts.body,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF81C784)
                                : const Color(0xFF2E7D32),
                          )),
                    ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!,
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colors.onSurfaceVariant)),
              ],
            ]),
          ),
          const SizedBox(width: 8),
          if (showToggle && toggleValue != null && onToggle != null)
            Semantics(
              label: option,
              child: Switch.adaptive(
                  value: toggleValue!,
                  onChanged: onToggle,
                  activeTrackColor: colors.primary,
                  activeThumbColor: colors.onPrimary),
            )
          else
            Icon(Icons.chevron_right_rounded,
                size: 20, color: colors.onSurfaceVariant),
        ]),
      ),
    );
  }
}
