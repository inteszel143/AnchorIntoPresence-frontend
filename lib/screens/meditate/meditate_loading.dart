import 'package:flutter/material.dart';
import '../../common/widgets/loading_skeleton.dart';

class MeditateLoadingSkeleton extends StatelessWidget {
  const MeditateLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => LoadingSkeleton(
        label: 'Loading library',
        child: Column(
          children: List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 8,
                    child: SkeletonBlock(height: double.infinity, radius: 17),
                  ),
                  SizedBox(height: 12),
                  Row(children: [
                    SkeletonBlock(width: 64, height: 14),
                    Spacer(),
                    SkeletonBlock(width: 40, height: 40, radius: 20),
                  ]),
                  SizedBox(height: 12),
                  FractionallySizedBox(
                    widthFactor: .75,
                    child: SkeletonBlock(height: 24),
                  ),
                  SizedBox(height: 12),
                  SkeletonBlock(height: 14),
                  SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: .6,
                    child: SkeletonBlock(height: 14),
                  ),
                  SizedBox(height: 14),
                  SkeletonBlock(width: 72, height: 26, radius: 13),
                ],
              ),
            ),
          ),
        ),
      );
}
