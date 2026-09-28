import 'package:flutter/material.dart';

/// A single accessible loading announcement around decorative placeholders.
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    lowerBound: .45,
    upperBound: .85,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
      _pulse.value = .7;
    } else {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: widget.label,
        liveRegion: true,
        child: ExcludeSemantics(
          child: IgnorePointer(
            child: FadeTransition(opacity: _pulse, child: widget.child),
          ),
        ),
      );
}

class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  final double width, height, radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
