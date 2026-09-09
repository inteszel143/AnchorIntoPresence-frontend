import 'package:mindfully_evolve_app/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../helping_widgets/activityitem_tile.dart';
import '../../utils/color_constants.dart';
import '../../utils/string_constants.dart';
import 'getactivity_bloc/getrecent_activities_bloc.dart';
import 'getactivity_bloc/getrecent_activities_event.dart';
import 'getactivity_bloc/getrecent_activities_state.dart';

// Displays the activities that the user has marked as favorites.
class FavouriteActivity extends StatelessWidget {
  const FavouriteActivity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Loads the available activities so favorite activities can be displayed.
      create: (_) => ActivityBloc()..add(FetchActivities()),
      child: Scaffold(
        backgroundColor: ColorCodes.backgroundcolor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppbar(
                headingTxt: Strings.favouriteActivities,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocListener<ActivityBloc, ActivityState>(
                  listener: (context, state) {
                    if (state is ActivityError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: ColorCodes.buttoncolor,
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<ActivityBloc, ActivityState>(
                    builder: (context, state) {
                      if (state is ActivityLoading) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: ColorCodes.buttoncolor,
                        ));
                      } else if (state is ActivityLoaded) {
                        // Filters the activity list to show only activities marked as favorites.
                        final activities = state.activities.activities
                            .where((activity) => activity.isFavorite == true)
                            .toList();
                        // Shows an empty state when the user has no favorite activities.
                        if (activities.isEmpty) {
                          return Center(
                            child: Text(
                              'No favorite activities',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontFamily: Fonts.body,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            // Displays each favorite activity with its details and available actions.
                            return ActivityItemTile(
                              id: activity.id,
                              heading: activity.name,
                              description: activity.description,
                              tags: activity.tags,
                              videoUrl: activity.video.replaceAll(' ', ''),
                              videoDuration: "5.00",
                              isLiked: activity.isFavorite,
                              thumbnail: activity.thumbnail,
                            );
                          },
                        );
                      } else if (state is ActivityError) {
                        return Center(child: Text(state.message));
                      } else {
                        return const Center(child: Text('unexpected error'));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
