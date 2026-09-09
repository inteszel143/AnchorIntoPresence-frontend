import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fix_strings.dart';
import '../../utils/image_constants.dart';
import '../../utils/share_options.dart';
import '../../utils/urls.dart';
import 'getactivity_bloc/getrecent_activities_bloc.dart';
import 'getactivity_bloc/getrecent_activities_event.dart';
import 'getactivity_bloc/getrecent_activities_state.dart';

// Displays the activities available under the selected meditation category.
class MeditationListing extends StatefulWidget {
  final String categoryId;

  const MeditationListing({Key? key, required this.categoryId})
      : super(key: key);

  @override
  State<MeditationListing> createState() => _MeditationListingState();
}

class _MeditationListingState extends State<MeditationListing> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Loads activities for the selected category when the screen is opened.
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

// Searches activities with a short delay to avoid unnecessary API requests while typing.
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

// Captures the activity image as a file so it can be shared with other users.
  Future<XFile?> captureWidget(GlobalKey key, String fileName) async {
    try {
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(
        pixelRatio: MediaQuery.of(key.currentContext!).devicePixelRatio,
      );

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.png');
      await file.writeAsBytes(pngBytes);

      return XFile(file.path);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Displays activity loading or API errors to the user.
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
                    hintText: Strings.search,
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
              BlocBuilder<ActivityBloc, ActivityState>(
                builder: (context, state) {
                  if (state is ActivityLoaded) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: state.activities.activities.length,
                        itemBuilder: (context, index) {
                          final GlobalKey repaintKey = GlobalKey();
                          final activity = state.activities.activities[index];
                          ValueNotifier<bool> isFavoriteNotifier =
                              ValueNotifier(activity.isFavorite);

                          return GestureDetector(
                            onTap: () {
                              // Opens a larger preview of the selected activity image.
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(16),
                                    child: Container(
                                      height: 280,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            RepaintBoundary(
                                                key: repaintKey,
                                                child: Image.network(
                                                  '${Urls.baseUrlimages}${activity.thumbnail}',
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.fitHeight,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                      child: Icon(
                                                          Icons.broken_image),
                                                    );
                                                  },
                                                )),
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      // Captures the preview image before opening the sharing options.
                                                      final XFile? imageFile =
                                                          await captureWidget(
                                                              repaintKey,
                                                              'activity');
                                                      if (imageFile != null) {
                                                        ShareUtils
                                                            .showShareOptionsWithImage(
                                                                context,
                                                                imageFile);
                                                      }
                                                    },
                                                    child: SvgPicture.asset(
                                                      ImageConstants.shareIcon,
                                                      color: ColorCodes
                                                          .backgroundcolor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 190,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  '${Urls.baseUrlimages}${activity.thumbnail}',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is ActivityError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
