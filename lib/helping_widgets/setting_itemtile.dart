import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/fonts.dart';

class SettingItemTile extends StatelessWidget {
  final String iconPath;
  final String option;
  final String? subtitle;
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
    this.destructive = false,
    this.showToggle = false,
    this.toggleValue,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
              Text(option,
                  style: TextStyle(
                      fontFamily: Fonts.body,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: foreground)),
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
