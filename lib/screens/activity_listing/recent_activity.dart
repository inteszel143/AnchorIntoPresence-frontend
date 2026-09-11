import 'package:flutter/material.dart';
import '../../common/widgets/collection_page.dart';
import '../../helping_widgets/activityitem_tile.dart';
import '../dashboard/home_dashboard.dart';
import '../dashboard/dashboard_bloc/recently_played_model.dart';

class RecentActivity extends StatelessWidget {
  final List<RecentlyPlayedActivity> recentlyPlayedActivities;
  const RecentActivity({super.key, required this.recentlyPlayedActivities});

  @override
  Widget build(BuildContext context) => CollectionPage(
        title: 'Recent Activities',
        description:
            'Pick up where you left off, or revisit a familiar practice.',
        slivers: [
          if (recentlyPlayedActivities.isEmpty)
            SliverToBoxAdapter(
                child: CollectionMessage(
              icon: Icons.self_improvement_rounded,
              title: 'Your next moment starts here',
              description:
                  'The practices you play will appear here, ready for you to return to.',
              action: OutlinedButton.icon(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to your practice')),
            ))
          else ...[
            SliverToBoxAdapter(
                child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                  '${recentlyPlayedActivities.length} recent ${recentlyPlayedActivities.length == 1 ? 'practice' : 'practices'}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            )),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              final activity = recentlyPlayedActivities[index];
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                            activity.isCompleted
                                ? 'Completed · Practice again'
                                : 'Last played ${activity.videoTimestamp}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant))),
                    ActivityItemTile(
                        key: ValueKey(activity.id),
                        collectionStyle: true,
                        id: activity.id,
                        heading: activity.name,
                        description: activity.description,
                        tags: activity.tagNames,
                        videoUrl: HomeDashboard.imageUrl(activity.video),
                        videoDuration: activity.totalVideoTime,
                        isLiked: activity.isFavorite,
                        thumbnail: activity.thumbnail),
                  ]);
            }, childCount: recentlyPlayedActivities.length)),
          ],
        ],
      );
}
