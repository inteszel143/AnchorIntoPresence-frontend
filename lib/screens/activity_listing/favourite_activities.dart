import '../../common/widgets/scroll_title_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../helping_widgets/activityitem_tile.dart';
import 'getactivity_bloc/getrecent_activities_bloc.dart';
import 'activity_list_cache.dart';
import 'getactivity_bloc/getrecent_activities_event.dart';
import 'getactivity_bloc/getrecent_activities_state.dart';

class FavouriteActivity extends StatelessWidget {
  const FavouriteActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityBloc()..add(FetchActivities(useCache: true)),
      child: Scaffold(
        body: ScrollTitlePage(
          title: 'Favorite Meditations',
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                          builder: (context) => CustomAppbar(
                                headingTxt: '',
                                okimage: const Tooltip(
                                    message: 'Refresh favorites',
                                    child: Icon(Icons.refresh_rounded)),
                                onOkTap: () {
                                  ActivityListCache.clear();
                                  context
                                      .read<ActivityBloc>()
                                      .add(FetchActivities(useCache: true));
                                },
                              )),
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  Text('Favorite Meditations',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Text(
                                      'A collection of moments worth returning to.',
                                      style: TextStyle(
                                          fontSize: 15,
                                          height: 1.5,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
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
                                      child: _message(
                                    context,
                                    icon: Icons.wifi_off_rounded,
                                    title: 'Your collection couldn’t load',
                                    description:
                                        'Please try again in a moment.',
                                    action: OutlinedButton.icon(
                                        onPressed: () => context
                                            .read<ActivityBloc>()
                                            .add(FetchActivities(
                                                useCache: true)),
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
                                      child: _message(
                                    context,
                                    icon: Icons.favorite_border_rounded,
                                    title: 'Keep a little calm close',
                                    description:
                                        'Tap the heart on a meditation to save it here. Your favorites will be ready whenever you need a pause.',
                                    action: OutlinedButton.icon(
                                        onPressed: () =>
                                            Navigator.maybePop(context),
                                        icon: const Icon(
                                            Icons.arrow_back_rounded),
                                        label: const Text(
                                            'Back to your practice')),
                                  ));
                                }
                                return SliverPadding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        if (index == 0) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 14),
                                            child: Text(
                                                '${activities.length} saved ${activities.length == 1 ? 'meditation' : 'meditations'}',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: colors
                                                        .onSurfaceVariant)),
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
                                          videoUrl: activity.video
                                              .replaceAll(' ', ''),
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
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _message(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required Widget action}) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          CircleAvatar(
              radius: 30,
              backgroundColor: colors.surface,
              child: Icon(icon, size: 28, color: colors.primary)),
          const SizedBox(height: 20),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(description,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: colors.onSurfaceVariant, height: 1.6, fontSize: 14)),
          const SizedBox(height: 24),
          action,
        ]),
      ),
    );
  }
}
