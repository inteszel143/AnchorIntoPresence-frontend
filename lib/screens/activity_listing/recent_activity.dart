import 'package:flutter/material.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../helping_widgets/activityitem_tile.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';
import '../../utils/urls.dart';
import '../dashboard/dashboard_bloc/recently_played_model.dart';

// Displays the user's recently played activities.
class RecentActivity extends StatelessWidget {
  final List<RecentlyPlayedActivity> recentlyPlayedActivities;

  const RecentActivity({
    Key? key,
    required this.recentlyPlayedActivities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCodes.backgroundcolor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar(
              headingTxt: Strings.recentActivities,
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Expanded(
              // Shows a message when there are no recently played activities.
              child: recentlyPlayedActivities.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          "Your activities will be displayed here",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorCodes.mainheadingcolor,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            fontFamily: Fonts.body,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: recentlyPlayedActivities.length,
                      itemBuilder: (context, index) {
                        final activity = recentlyPlayedActivities[index];
                        // Displays each recently played activity with its details and current status.
                        return ActivityItemTile(
                          id: activity.id,
                          heading: activity.name,
                          description: activity.description,
                          tags: activity.tagNames,
                          videoUrl: '${Urls.baseUrlimages}${activity.video}',
                          videoDuration: activity.totalVideoTime,
                          isLiked: activity.isFavorite,
                          thumbnail: activity.thumbnail,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
