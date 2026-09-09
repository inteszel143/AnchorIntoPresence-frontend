import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

/// Theme-aware circular control shared by page headers.
class AppCircleButton extends StatelessWidget {
  const AppCircleButton(
      {super.key, required this.icon, this.onPressed, this.tooltip});

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final button = SizedBox.square(
      dimension: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surfaceContainerHighest,
        ),
        child: AdaptiveButton.child(
          onPressed: onPressed,
          enabled: onPressed != null,
          style: AdaptiveButtonStyle.glass,
          size: AdaptiveButtonSize.large,
          color: colors.surfaceContainerHighest,
          minSize: const Size(44, 44),
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(22),
          useSmoothRectangleBorder: false,
          child: IconTheme(
            data: IconThemeData(
                size: 24,
                color: onPressed != null
                    ? colors.onSurface
                    : colors.onSurfaceVariant),
            child: SizedBox.square(dimension: 24, child: icon),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
