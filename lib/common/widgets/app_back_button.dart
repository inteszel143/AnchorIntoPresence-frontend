import 'package:flutter/material.dart';
import 'app_circle_button.dart';

/// Shared circular back control for headers and standalone page navigation.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed, this.icon});

  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => AppCircleButton(
        tooltip: 'Back',
        onPressed: onPressed ??
            () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
        icon: icon ?? const Icon(Icons.arrow_back_rounded),
      );
}
