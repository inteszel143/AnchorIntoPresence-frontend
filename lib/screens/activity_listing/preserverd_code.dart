import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/image_constants.dart';
import '../../utils/string_constants.dart';
import 'getactivity_bloc/getrecent_activities_bloc.dart';
import 'getactivity_bloc/getrecent_activities_event.dart';
import 'getactivity_bloc/getrecent_activities_state.dart';

class MeditationListingCode extends StatelessWidget {
  final List? gracefulGrounding;
  final List? dailyTouchstone;
  MeditationListingCode(
      {super.key, this.gracefulGrounding, this.dailyTouchstone});

  final TextEditingController searchController = TextEditingController();
  bool isDescSort = true;
  String currentSortOrder = 'desc';

  Future<String> _getVideoDuration(String url) async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      final duration = controller.value.duration;
      controller.dispose();
      final minutes =
          duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds =
          duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    } catch (e) {
      return "--:--";
    }
  }

  @override
  Widget build(BuildContext context) {
    final recomended = [
      {"img": ImageConstants.recommendedImage},
      {"img": ImageConstants.recommendedImage},
      {"img": ImageConstants.recommendedImage},
      {"img": ImageConstants.recommendedImage},
      {"img": ImageConstants.recommendedImage},
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityBloc>().add(FetchActivities(search: ''));
    });

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
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 25, 17, 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: Strings.searchMeditation,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: GestureDetector(
                              onTap: () {
                                final searchQuery =
                                    searchController.text.trim();
                                context.read<ActivityBloc>().add(
                                      FetchActivities(search: searchQuery),
                                    );
                              },
                              child: SvgPicture.asset(
                                ImageConstants.svgSearchIcon,
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: ColorCodes.whitecolor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        isDescSort = !isDescSort;
                        currentSortOrder = isDescSort ? 'desc' : 'asc';
                        final searchQuery = searchController.text;
                        context.read<ActivityBloc>().add(
                              FetchActivities(
                                  search: searchQuery,
                                  sortOrder: currentSortOrder),
                            );
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: ColorCodes.buttoncolor,
                          borderRadius: BorderRadius.circular(14),
                          image: DecorationImage(
                            image: AssetImage(ImageConstants.listingIcon),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        "Recommended",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          letterSpacing: Fonts.headingLetterSpacing,
                          fontFamily: Fonts.heading,
                          color: ColorCodes.mainheadingcolor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 118,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recomended.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 245,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage(recomended[index]['img']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (gracefulGrounding!.isNotEmpty) ...[
                Expanded(
                  // This will make sure the ListView takes up available space
                  child: ListView.builder(
                    itemCount: gracefulGrounding
                        ?.length, // The number of items in gracefulGrounding
                    itemBuilder: (context, index) {
                      final item =
                          gracefulGrounding?[index]; // Access each activity

                      return GestureDetector(
                        onTap: () {
                          // Show dialog with description
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(16),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEED6D3),
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
                                      Flexible(
                                        child: SingleChildScrollView(
                                          child: Text(
                                            item.description ??
                                                '', // Use the description from the ActivityData object
                                            maxLines: 4,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: Fonts.headingLetterSpacing,
                                              fontFamily: Fonts.heading,
                                              color: Colors.black,
                                            ),
                                          ),
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
                          width: double
                              .infinity, // Allow the container to expand to full width
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8), // Space between cards
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEED6D3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // Content of the item (e.g., description)
                              Center(
                                child: AutoSizeText(
                                  item.description ??
                                      '', // Access the description property correctly
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  minFontSize: 14,
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
                              // Like icon at the top-right corner
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    BlocProvider.of<ActivityBloc>(context).add(
                                      ToggleFavorite(activityId: item.id),
                                    );
                                  },
                                  child: Icon(
                                    Icons.favorite,
                                    color: item.isFavorite
                                        ? Colors.red
                                        : Colors
                                            .white, // Red if liked, white otherwise
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
