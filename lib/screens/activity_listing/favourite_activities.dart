import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/collection_page.dart';
import '../../helping_widgets/activityitem_tile.dart';
import 'getactivity_bloc/getrecent_activities_bloc.dart';
import 'activity_list_cache.dart';
import 'getactivity_bloc/getrecent_activities_event.dart';
import 'getactivity_bloc/getrecent_activities_state.dart';

class FavouriteActivity extends StatelessWidget {
  const FavouriteActivity({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ActivityBloc()..add(FetchActivities(useCache: true)),
        child: Builder(
            builder: (context) => CollectionPage(
                  title: 'Favorites',
                  description: 'Your saved moments of calm, all in one place.',
                  onRefresh: () {
                    ActivityListCache.clear();
                    context
                        .read<ActivityBloc>()
                        .add(FetchActivities(useCache: true));
                  },
                  slivers: [
                    BlocConsumer<ActivityBloc, ActivityState>(
                      listener: (context, state) {
                        if (state is ActivityFavouriteLoaded) {
                          context
                              .read<ActivityBloc>()
                              .add(FetchActivities(useCache: true));
                        }
                      },
                      buildWhen: (_, state) =>
                          state is! ActivityFavouriteLoaded,
                      builder: (context, state) {
                        final colors = Theme.of(context).colorScheme;
                        if (state is ActivityError) {
                          return SliverToBoxAdapter(
                              child: CollectionMessage(
                            icon: Icons.wifi_off_rounded,
                            title: 'Your collection couldn’t load',
                            description: 'Please try again in a moment.',
                            action: OutlinedButton.icon(
                                onPressed: () => context
                                    .read<ActivityBloc>()
                                    .add(FetchActivities(useCache: true)),
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Try again')),
                          ));
                        }
                        if (state is! ActivityLoaded) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                                child: CircularProgressIndicator(
                                    semanticsLabel:
                                        'Loading favorite meditations')),
                          );
                        }
                        final activities = state.activities.activities
                            .where((activity) => activity.isFavorite)
                            .toList();
                        if (activities.isEmpty) {
                          return SliverToBoxAdapter(
                              child: CollectionMessage(
                            icon: Icons.favorite_border_rounded,
                            title: 'Keep a little calm close',
                            description:
                                'Tap the heart on a meditation to save it here. Your favorites will be ready whenever you need a pause.',
                            action: OutlinedButton.icon(
                                onPressed: () => Navigator.maybePop(context),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('Back to your practice')),
                          ));
                        }
                        return SliverPadding(
                          padding: const EdgeInsets.only(bottom: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Text(
                                        '${activities.length} saved ${activities.length == 1 ? 'meditation' : 'meditations'}',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: colors.onSurfaceVariant)),
                                  );
                                }
                                final activity = activities[index - 1];
                                return ActivityItemTile(
                                  key: ValueKey(activity.id),
                                  collectionStyle: true,
                                  id: activity.id,
                                  heading: activity.name,
                                  description: activity.description,
                                  tags: activity.tags,
                                  videoUrl: activity.video.replaceAll(' ', ''),
                                  videoDuration: '--:--',
                                  isLiked: activity.isFavorite,
                                  thumbnail: activity.thumbnail,
                                );
                              },
                              childCount: activities.length + 1,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )),
      );
}
