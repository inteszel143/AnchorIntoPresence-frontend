import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets/daily_pause_preview.dart';
import '../activity_details/activity_bloc/post_activity_bloc.dart';
import '../activity_details/activity_details.dart';
import '../activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import '../activity_listing/getactivity_bloc/getrecent_activities_event.dart';
import '../activity_listing/getactivity_model.dart';
import '../dashboard/home_dashboard.dart';

/// Portrait artwork for browsing; full details remain in the practice screen.
class LibraryPracticeCard extends StatelessWidget {
  const LibraryPracticeCard({super.key, required this.activity});
  final Activity activity;

  Future<void> _open(BuildContext context) async {
    if (activity.isDailyPause) {
      await showDailyPausePreview(context,
          title: activity.name, thumbnail: activity.thumbnail);
      return;
    }
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => PostActivityBloc(),
        child: ActivityDetailScreen(
          videoUrl: activity.video.replaceAll(' ', ''),
          thumbnail: null,
          thumbnailUrl: HomeDashboard.imageUrl(activity.thumbnail),
          name: activity.name,
          duration: '--:--',
          tags: activity.tags,
          description: activity.description,
          activityId: activity.id,
          isFavorite: activity.isFavorite,
        ),
      ),
    ));
    if (changed == true && context.mounted) {
      context.read<ActivityBloc>().add(FetchActivities(useCache: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: '${activity.name}, ${activity.categoryLabel}',
      button: true,
      child: Material(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          if (activity.thumbnail.isNotEmpty)
            Image.network(HomeDashboard.imageUrl(activity.thumbnail),
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, __, ___) => _fallback(colors))
          else
            _fallback(colors),
          // The reference uses a dark scrim to keep editable titles readable.
          const DecoratedBox(
              decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, .4, 1],
              colors: [Color(0x16000000), Color(0x00000000), Color(0xE6000000)],
            ),
          )),
          Material(
            color: Colors.transparent,
            child: InkWell(onTap: () => _open(context)),
          ),
          Positioned(
            top: 14,
            left: 14,
            right: 54,
            child: IgnorePointer(
                child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0x99000000),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                      activity.isDailyPause
                          ? Icons.spa_outlined
                          : Icons.self_improvement_rounded,
                      color: Colors.white,
                      size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                      child: Text(
                    (activity.categoryLabel.isEmpty
                            ? 'Practice'
                            : activity.categoryLabel)
                        .toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .3),
                  )),
                ]),
              ),
            )),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              tooltip: activity.isFavorite
                  ? 'Remove from favorites'
                  : 'Save practice',
              style: IconButton.styleFrom(
                  backgroundColor: const Color(0x99000000),
                  foregroundColor: Colors.white),
              icon: Icon(
                  activity.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20),
              onPressed: () => context
                  .read<ActivityBloc>()
                  .add(ToggleFavorite(activityId: activity.id)),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 20,
            child: IgnorePointer(
                child: Text(
              activity.name,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
            )),
          ),
        ]),
      ),
    );
  }

  Widget _fallback(ColorScheme colors) => ColoredBox(
        color: colors.secondaryContainer,
        child: Center(
            child: Icon(Icons.spa_outlined,
                size: 48, color: colors.onSecondaryContainer)),
      );
}
