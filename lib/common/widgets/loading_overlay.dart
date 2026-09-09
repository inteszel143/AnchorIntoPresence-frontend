import 'dart:ui';

import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: AbsorbPointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
