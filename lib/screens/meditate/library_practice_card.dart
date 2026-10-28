import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets/daily_pause_preview.dart';
import '../../common/widgets/practice_artwork_card.dart';
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
  Widget build(BuildContext context) => PracticeArtworkCard(
        title: activity.name,
        categoryLabel: activity.categoryLabel,
        imageUrl: activity.thumbnail.isEmpty
            ? ''
            : HomeDashboard.imageUrl(activity.thumbnail),
        isDailyPause: activity.isDailyPause,
        isFavorite: activity.isFavorite,
        onTap: () => _open(context),
        onFavorite: () => context
            .read<ActivityBloc>()
            .add(ToggleFavorite(activityId: activity.id)),
      );
}
