import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../helping_widgets/activityitem_tile.dart';
import '../../utils/color_constants.dart';
import '../../utils/fix_strings.dart';
import '../../utils/image_constants.dart';
import 'getactivity_bloc/getrecent_activities_bloc.dart';
import 'getactivity_bloc/getrecent_activities_event.dart';
import 'getactivity_bloc/getrecent_activities_state.dart';

// Displays the daily meditation activities available under the selected category.
class MeditationListingDaily extends StatefulWidget {
  final String categoryId;

  const MeditationListingDaily({Key? key, required this.categoryId})
      : super(key: key);

  @override
  State<MeditationListingDaily> createState() => _MeditationListingDailyState();
}

class _MeditationListingDailyState extends State<MeditationListingDaily> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Loads the daily meditation activities for the selected category when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ActivityBloc>()
          .add(FetchActivities(categoryId: widget.categoryId, search: ''));
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

// Searches meditation activities with a short delay to avoid unnecessary API requests while typing.
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ActivityBloc>().add(
            FetchActivities(
              categoryId: widget.categoryId,
              search: query.trim(),
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Handles activity API errors and displays a user-friendly message.
    return BlocListener<ActivityBloc, ActivityState>(
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
      child: Scaffold(
        backgroundColor: ColorCodes.backgroundcolor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppbar(headingTxt: ''),
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 25, 17, 15),
                child: TextField(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: Strings.searchMeditation,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SvgPicture.asset(
                        ImageConstants.svgSearchIcon,
                        width: 24,
                        height: 24,
                      ),
                    ),
                    filled: true,
                    fillColor: ColorCodes.whiteNewReplacement,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<ActivityBloc, ActivityState>(
                  builder: (context, state) {
                    if (state is ActivityError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is ActivityLoaded) {
                      final activities = state.activities;
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: activities.activities.length,
                        itemBuilder: (context, index) {
                          final activity = activities.activities[index];
                          // Displays each meditation activity with its details, progress options, and favorite status.
                          return ActivityItemTile(
                            heading: activity.name,
                            description: activity.description,
                            tags: activity.tags,
                            videoUrl: activity.video.replaceAll(' ', ''),
                            videoDuration: "5.00",
                            thumbnail: activity.thumbnail,
                            isLiked: activity.isFavorite,
                            id: activity.id,
                            categoryId: widget.categoryId,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
