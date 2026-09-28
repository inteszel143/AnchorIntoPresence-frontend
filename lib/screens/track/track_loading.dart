import 'package:flutter/material.dart';
import '../../common/widgets/loading_skeleton.dart';

class TrackLoadingSkeleton extends StatelessWidget {
  const TrackLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => LoadingSkeleton(
        label: 'Loading your practice history',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(width: 170, height: 20),
                  SizedBox(height: 14),
                  SkeletonBlock(height: 32),
                  SizedBox(height: 20),
                  SkeletonBlock(width: 150, height: 18),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SkeletonBlock(width: 190, height: 26),
            const SizedBox(height: 10),
            const SkeletonBlock(width: 240, height: 14),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: SkeletonBlock(width: 140, height: 22)),
                  const SizedBox(height: 20),
                  for (var row = 0; row < 6; row++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: List.generate(
                            7,
                            (_) => Expanded(
                                  child: Center(
                                    child: SkeletonBlock(
                                      width: row == 0 ? 20 : 28,
                                      height: row == 0 ? 12 : 28,
                                      radius: row == 0 ? 4 : 14,
                                    ),
                                  ),
                                )),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const SkeletonBlock(width: 160, height: 12),
                  const SizedBox(height: 24),
                  const SkeletonBlock(width: 200, height: 14),
                ],
              ),
            ),
          ],
        ),
      );
}
