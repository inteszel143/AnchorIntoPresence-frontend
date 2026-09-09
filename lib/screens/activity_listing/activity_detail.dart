import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../utils/Colors.dart';
import '../../utils/fonts.dart';
import '../../utils/image_constants.dart';
import '../../utils/share_options.dart';
import '../../utils/urls.dart';
import 'getactivity_bloc/getrecent_activities_bloc.dart';
import 'getactivity_bloc/getrecent_activities_event.dart';
import 'getactivity_bloc/getrecent_activities_state.dart';

// Displays the details of a selected activity and provides favorite and sharing options.
class ActivityDetail extends StatelessWidget {
  final String activityId;

  const ActivityDetail({super.key, required this.activityId});
  @override
  Widget build(BuildContext context) {
    // Fetches the selected activity details when the screen is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityBloc>().add(FetchActivity(activityId: activityId));
    });
// Handles activity-related errors and displays them to the user.
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
        backgroundColor: const Color(0xffF0EAE6),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppbar(headingTxt: ''),
              BlocBuilder<ActivityBloc, ActivityState>(
                builder: (context, state) {
                  // Displays a loading indicator while activity details are being fetched.
                  if (state is ActivityLoading) {
                    return const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state is ActivityLoad) {
                    final activity = state.activity;
                    final isFavoriteNotifier =
                        ValueNotifier(activity.isFavorite);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () {
                            // Shows the complete activity description when the user taps the activity card.
                            showDialog(
                              context: context,
                              builder: (_) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: const EdgeInsets.all(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4DADA),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: const Icon(Icons.close),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          activity.description,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            letterSpacing: Fonts.headingLetterSpacing,
                                            fontFamily: Fonts.heading,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 300,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: AssetImage(
                                    ImageConstants.anchorOfLoveBackground),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    activity.description,
                                    textAlign: TextAlign.center,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: Fonts.headingLetterSpacing,
                                      fontFamily: Fonts.heading,
                                      color: Colors.black,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Row(
                                    children: [
                                      ValueListenableBuilder<bool>(
                                        valueListenable: isFavoriteNotifier,
                                        builder: (context, isFavorite, child) {
                                          return GestureDetector(
                                            onTap: () {
                                              isFavoriteNotifier.value =
                                                  !isFavorite;
                                              // Updates the favorite status of the selected activity.
                                              context.read<ActivityBloc>().add(
                                                  ToggleFavorite(
                                                      activityId: activity.id));
                                            },
                                            child: Icon(
                                              Icons.favorite,
                                              color: isFavorite
                                                  ? Colors.red
                                                  : Colors.white,
                                              size: 24,
                                            ),
                                          );
                                        },
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          String postMessage =
                                              "Check out this amazing activity!";
                                          String postUrl =
                                              '${Urls.baseUrl}/app/anchorOfLove/share/${activity.id}';
                                          // Opens the available sharing options with a shareable activity link.
                                          ShareUtils.showShareOptions(
                                              context, postMessage, postUrl);
                                        },
                                        child: SvgPicture.asset(
                                          ImageConstants.shareIcon,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is ActivityError) {
                    return Expanded(
                      child: Center(child: Text(state.message)),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
