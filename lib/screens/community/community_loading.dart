import 'package:flutter/material.dart';
import '../../common/widgets/loading_skeleton.dart';

class CommunityLoadingSkeleton extends StatelessWidget {
  const CommunityLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => LoadingSkeleton(
        label: 'Loading community posts',
        child: Column(
          children: List.generate(3, (index) => _post(context, index == 0)),
        ),
      );

  Widget _post(BuildContext context, bool withImage) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              SkeletonBlock(width: 44, height: 44, radius: 22),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(width: 130, height: 16),
                    SizedBox(height: 8),
                    SkeletonBlock(width: 75, height: 12),
                  ],
                ),
              ),
            ]),
            if (withImage) ...[
              const SizedBox(height: 18),
              const SkeletonBlock(height: 220, radius: 18),
            ],
            const SizedBox(height: 16),
            const SkeletonBlock(height: 14),
            const SizedBox(height: 10),
            const FractionallySizedBox(
              widthFactor: .7,
              child: SkeletonBlock(height: 14),
            ),
            const SizedBox(height: 24),
            const Wrap(spacing: 16, runSpacing: 8, children: [
              SkeletonBlock(width: 64, height: 28, radius: 14),
              SkeletonBlock(width: 64, height: 28, radius: 14),
            ]),
          ],
        ),
      );
}
