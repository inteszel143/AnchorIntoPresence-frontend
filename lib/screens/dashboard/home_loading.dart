import 'package:flutter/material.dart';

/// A short, staggered entrance that does not replay on ordinary data rebuilds.
class HomeSectionEntrance extends StatelessWidget {
  const HomeSectionEntrance(
      {super.key, required this.order, required this.child});

  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delay = order * 70;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Interval(delay / (420 + delay), 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

/// Mirrors the home layout while the initial profile and practices load.
class HomeLoadingSkeleton extends StatefulWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  State<HomeLoadingSkeleton> createState() => _HomeLoadingSkeletonState();
}

class _HomeLoadingSkeletonState extends State<HomeLoadingSkeleton>
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget block(double width, double height, {double radius = 8}) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: colors.onSurface.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
    Widget practice() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              block(32, 32, radius: 16),
              const SizedBox(width: 10),
              block(120, 18),
            ]),
            const SizedBox(height: 10),
            block(220, 12),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                block(80, 96, radius: 14),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      block(double.infinity, 18),
                      const SizedBox(height: 10),
                      block(90, 12),
                      const SizedBox(height: 22),
                      block(double.infinity, 16),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        );
    return Semantics(
      label: 'Loading your home screen',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: FadeTransition(
              opacity: _pulse,
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          block(50, 26),
                          const SizedBox(height: 10),
                          block(100, 30),
                        ],
                      ),
                    ),
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: block(40, 40, radius: 20),
                      ),
                  ]),
                  const SizedBox(height: 24),
                  Align(alignment: Alignment.centerLeft, child: block(200, 24)),
                  const SizedBox(height: 10),
                  block(double.infinity, 14),
                  const SizedBox(height: 24),
                  practice(),
                  const SizedBox(height: 40),
                  practice(),
                  const SizedBox(height: 32),
                  Align(alignment: Alignment.centerLeft, child: block(190, 24)),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: block(double.infinity, 240, radius: 24)),
                    const SizedBox(width: 14),
                    Expanded(child: block(double.infinity, 240, radius: 24)),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
