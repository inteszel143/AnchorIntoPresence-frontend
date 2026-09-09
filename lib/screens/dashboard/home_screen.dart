import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management.dart';
import 'package:mindfully_evolve_app/utils/urls.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/global.dart' as globals;
import '../../utils/image_constants.dart';
import '../../utils/share_options.dart';
import '../activity_details/activity_bloc/post_activity_bloc.dart';
import '../activity_details/activity_details.dart';
import '../activity_listing/activity_listing.dart';
import '../activity_listing/activity_listing_daily.dart';
import '../activity_listing/recent_activity.dart';
import '../notification/notification_bloc/notification_bloc.dart';
import '../notification/notificaton_screen.dart';
import '../subscriptionmanagement/subscription_management_bloc/subscriprion_management_bloc.dart';
import '../subscriptionmanagement/subscription_management_bloc/subscriprion_management_event.dart';
import '../user_profile/userprofile_screen.dart';
import 'dashboard_bloc/home_bloc.dart';
import 'dashboard_bloc/home_event.dart';
import 'dashboard_bloc/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  bool isDescSort = true;
  String currentSortOrder = 'desc';
  Timer? _debounce;

  // Create the bloc once, outside of build, so it isn't recreated on every rebuild
  late HomePageBloc _homePageBloc;

  @override
  void initState() {
    super.initState();
    _homePageBloc = HomePageBloc()
      ..add(FetchHomePageDataEvent(context: context));
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    _homePageBloc.close();
    super.dispose();
  }

  Future<Uint8List> fetchImageBytes(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

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
      print("Error fetching video duration: $e");
      return "--:--";
    }
  }

  Future<XFile?> getWidgetImagea(GlobalKey key, String fileName) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.png');
      await file.writeAsBytes(pngBytes);

      return XFile(file.path);
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

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
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  Future<XFile?> getWidgetImaged(GlobalKey key, String fileName) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image originalImage = await boundary.toImage(pixelRatio: 3);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final paint = Paint();
      final size =
          Size(originalImage.width.toDouble(), originalImage.height.toDouble());

      canvas.translate(0, size.height);
      canvas.scale(1, -1);
      canvas.drawImage(originalImage, Offset.zero, paint);

      final picture = recorder.endRecording();
      final flippedImage =
          await picture.toImage(originalImage.width, originalImage.height);
      final byteData =
          await flippedImage.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.png');
      await file.writeAsBytes(pngBytes);

      return XFile(file.path);
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      BlocProvider.of<SubscriptionBloc>(context).add(FetchBillingHistory());
    });
    return Stack(
      children: [
        Scaffold(
          backgroundColor: ColorCodes.backgroundcolor,
          body: SafeArea(
            child: BlocProvider.value(
              value: _homePageBloc,
              child: BlocBuilder<HomePageBloc, HomePageState>(
                builder: (context, state) {
                  // Only show full-screen spinner on the very first load,
                  // when there's no previous data to show yet.
                  if (state is HomePageLoadingState) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is HomePageNoDataState) {
                    return _buildSearchBarOnly(context);
                  } else if (state is HomePageErrorState) {
                    return Center(child: Text('Error: ${state.errorMessage}'));
                  } else if (state is HomePageLoadedState) {
                    final homePageData = state.homePageData;
                    final profileData = state.profileData;
                    final gracefulGrounding =
                        homePageData.data['Daily Pause']?.activities ?? [];
                    final soulfulMeditations =
                        homePageData.data['Daily Anchor']?.activities ?? [];
                    final String profileImageUrl =
                        profileData.image != null ? '${profileData.image}' : '';
                    final String userName = profileData.name;
                    final DateTime createdAtDate = profileData.createdAt;
                    final String? subscriptionStatus =
                        profileData.subscriptionStatus;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      decoration: BoxDecoration(
                                        color: ColorCodes.settingDarkContainer,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ColorCodes.black12color,
                                            blurRadius: 8,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const UserprofileScreen()),
                                                    );
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage: profileImageUrl
                                                            .isNotEmpty
                                                        ? NetworkImage(
                                                            '${Urls.baseUrlimages}$profileImageUrl')
                                                        : AssetImage(
                                                                ImageConstants
                                                                    .userProfile)
                                                            as ImageProvider,
                                                  )),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Good Morning, ',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                Fonts.body,
                                                            color: ColorCodes
                                                                .blackcolor,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            (userName != null &&
                                                                    userName
                                                                        .trim()
                                                                        .isNotEmpty)
                                                                ? userName
                                                                    .trim()
                                                                    .split(' ')
                                                                    .first
                                                                : 'Anderson',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              letterSpacing: Fonts.headingLetterSpacing,
                                                              fontFamily: Fonts.heading,
                                                              color: ColorCodes
                                                                  .blackcolor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      'What is true for you in this moment?',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        letterSpacing: Fonts.headingLetterSpacing,
                                                        fontFamily:
                                                            Fonts.heading,
                                                        color: ColorCodes
                                                            .blackcolor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  final notificationBloc =
                                                      BlocProvider.of<
                                                              NotificationBloc>(
                                                          context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          BlocProvider.value(
                                                        value: notificationBloc,
                                                        child:
                                                            NotificatonScreen(),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: SvgPicture.asset(
                                                  ImageConstants.bellIcon,
                                                  width: 30,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16, top: 20),
                                          child: Text(
                                            "Daily Anchor",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  ColorCodes.mainheadingcolor,
                                              // fontFamily: Fonts.heading,
                                              letterSpacing: Fonts.headingLetterSpacing,
                                              fontFamily: Fonts.heading,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      MeditationListingDaily(
                                                        categoryId: soulfulMeditations
                                                                .isNotEmpty
                                                            ? soulfulMeditations
                                                                .first
                                                                .categoryId
                                                            : "68652bd4f1726792092bffaf",
                                                      )),
                                            );
                                            if (!mounted) return;
                                            _homePageBloc.add(
                                              FetchHomePageDataEvent(
                                                context: context,
                                                isSearch: true,
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10, top: 20),
                                            child: Text(
                                              "Browse All >",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    ColorCodes.mainheadingcolor,
                                                fontFamily: Fonts.body,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 152,
                                      child: soulfulMeditations.isEmpty
                                          ? Center(
                                              child: Text(
                                                "Today’s Meditation is on its way. \nPlease check back shortly.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorCodes
                                                      .mainheadingcolor,
                                                  fontFamily: Fonts.body,
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    soulfulMeditations.length,
                                                shrinkWrap: true,
                                                physics:
                                                    const AlwaysScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  final item =
                                                      soulfulMeditations[index];
                                                  final createdDate = item
                                                              .createdAt !=
                                                          null
                                                      ? DateFormat('MMM d')
                                                          .format(
                                                              item.createdAt!)
                                                      : '--';
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 2, 0, 10),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        final String imageUrl =
                                                            '${Urls.baseUrlimages}${item.thumbnail}';
                                                        try {
                                                          final Uint8List
                                                              thumbBytes =
                                                              await fetchImageBytes(
                                                                  imageUrl);
                                                          final String
                                                              duration =
                                                              await _getVideoDuration(
                                                                  '${Urls.baseUrlimages}${item.video}');
                                                          await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  BlocProvider(
                                                                create: (_) =>
                                                                    PostActivityBloc(),
                                                                child:
                                                                    ActivityDetailScreen(
                                                                  videoUrl:
                                                                      '${Urls.baseUrlimages}${item.video}',
                                                                  thumbnail:
                                                                      thumbBytes,
                                                                  name:
                                                                      item.name,
                                                                  duration:
                                                                      duration,
                                                                  tags:
                                                                      item.tagName ??
                                                                          [],
                                                                  description: item
                                                                      .description,
                                                                  activityId:
                                                                      item.id,
                                                                  isFavorite: item
                                                                      .isFavorite,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                          // Refresh so Recently
                                                          // Played reflects what was
                                                          // just watched, without
                                                          // requiring an app restart.
                                                          if (!mounted) return;
                                                          _homePageBloc.add(
                                                            FetchHomePageDataEvent(
                                                              context: context,
                                                              isSearch: true,
                                                            ),
                                                          );
                                                        } catch (e) {
                                                          debugPrint(
                                                              'Failed to fetch image: $e');
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 245,
                                                        margin: const EdgeInsets
                                                            .only(left: 12),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              child:
                                                                  Image.network(
                                                                '${Urls.baseUrlimages}${item.thumbnail}',
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: double
                                                                    .infinity,
                                                                height: double
                                                                    .infinity,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16, top: 20),
                                          child: Text(
                                            "Daily Pause",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  ColorCodes.mainheadingcolor,
                                              letterSpacing: Fonts.headingLetterSpacing,
                                              fontFamily: Fonts.heading,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16, top: 20),
                                          child: GestureDetector(
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => MeditationListing(
                                                        categoryId: gracefulGrounding
                                                                .isNotEmpty
                                                            ? gracefulGrounding
                                                                .first
                                                                .categoryId
                                                            : "686ccd3394924299a04db877")),
                                              );
                                              if (!mounted) return;
                                              _homePageBloc.add(
                                                FetchHomePageDataEvent(
                                                  context: context,
                                                  isSearch: true,
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Text(
                                                "Browse All >",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorCodes
                                                      .mainheadingcolor,
                                                  fontFamily: Fonts.body,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 152,
                                      child: gracefulGrounding.isEmpty
                                          ? Center(
                                              child: Text(
                                                "Today’s Reflection is on its way. \nPlease check back shortly.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorCodes
                                                      .mainheadingcolor,
                                                  fontFamily: Fonts.body,
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    gracefulGrounding.length,
                                                shrinkWrap: true,
                                                physics:
                                                    const AlwaysScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  final GlobalKey repaintKey =
                                                      GlobalKey();
                                                  final item =
                                                      gracefulGrounding[index];
                                                  return GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Dialog(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            insetPadding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            child: Container(
                                                              height: 190,
                                                              width: 450,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 12),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                child: Stack(
                                                                  fit: StackFit
                                                                      .expand,
                                                                  children: [
                                                                    RepaintBoundary(
                                                                      key:
                                                                          repaintKey,
                                                                      child: Image
                                                                          .network(
                                                                        '${Urls.baseUrlimages}${item.thumbnail}',
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            double.infinity,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) {
                                                                          return const Center(
                                                                            child:
                                                                                Icon(Icons.broken_image),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      top: 5,
                                                                      right: 5,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () async {
                                                                              final XFile? imageFile = await captureWidget(repaintKey, 'activity');
                                                                              if (imageFile != null) {
                                                                                ShareUtils.showShareOptionsWithImage(context, imageFile);
                                                                              }
                                                                            },
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              ImageConstants.shareIcon,
                                                                              color: ColorCodes.backgroundcolor,
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
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 12),
                                                      width: 245,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        child: Image.network(
                                                          '${Urls.baseUrlimages}${item.thumbnail}',
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return const Center(
                                                              child: Icon(Icons
                                                                  .broken_image),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                    ),

                                    if (state
                                        .recentlyPlayedData.isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, top: 20),
                                        child: Row(
                                          children: [
                                            const Text(
                                              "Recently Played",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    ColorCodes.mainheadingcolor,
                                                letterSpacing: Fonts.headingLetterSpacing,
                                                fontFamily: Fonts.heading,
                                              ),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () async {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        RecentActivity(
                                                      recentlyPlayedActivities:
                                                          state
                                                              .recentlyPlayedData,
                                                    ),
                                                  ),
                                                );
                                                if (!mounted) return;
                                                _homePageBloc.add(
                                                  FetchHomePageDataEvent(
                                                    context: context,
                                                    isSearch: true,
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: Text(
                                                  "Browse All >",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: ColorCodes
                                                        .mainheadingcolor,
                                                    fontFamily: Fonts.body,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 152,
                                        child: Center(
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                state.recentlyPlayedData.length,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              final item = state
                                                  .recentlyPlayedData[index];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 2, 0, 10),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    final String imageUrl =
                                                        '${Urls.baseUrlimages}${item.thumbnail}';
                                                    try {
                                                      final Uint8List
                                                          thumbBytes =
                                                          await fetchImageBytes(
                                                              imageUrl);

                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              BlocProvider(
                                                            create: (_) =>
                                                                PostActivityBloc(),
                                                            child:
                                                                ActivityDetailScreen(
                                                              videoUrl:
                                                                  '${Urls.baseUrlimages}${item.video}',
                                                              thumbnail:
                                                                  thumbBytes,
                                                              name: item.name,
                                                              duration: item
                                                                  .totalVideoTime,
                                                              tags:
                                                                  item.tagNames,
                                                              description: item
                                                                  .description,
                                                              activityId:
                                                                  item.id,
                                                              isFavorite: item
                                                                  .isFavorite,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                      // Refresh Recently Played
                                                      // (order/new plays) on return,
                                                      // no app restart needed.
                                                      if (!mounted) return;
                                                      _homePageBloc.add(
                                                        FetchHomePageDataEvent(
                                                          context: context,
                                                          isSearch: true,
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      debugPrint(
                                                          'Failed to fetch image: $e');
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 245,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 12),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: Image.network(
                                                        '${Urls.baseUrlimages}${item.thumbnail}',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return const Center(
                                                            child: Icon(Icons
                                                                .broken_image),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                    // ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('Unexpected error occurred.'));
                  }
                },
              ),
            ),
          ),
        ),
        if (globals.isSubscribed == false) ...[
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorCodes.settingLightContainer,
                    ColorCodes.settingLightContainer,
                    ColorCodes.settingLightContainer,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(35, 50, 35, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "This space is waiting for you.\n"
                      "Subscribe to unlock your full daily grounding and meditation practice… and begin each day grounded, calm, and aligned.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontFamily: Fonts.body,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubscriptionManagementScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: ColorCodes.buttoncolor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Step in",
                            style: const TextStyle(
                              color: ColorCodes.whitecolor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: Fonts.body,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ],
    );
  }

  Widget _buildSearchBarOnly(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: (query) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                _homePageBloc.add(
                  FetchHomePageDataEvent(
                    searchQuery: query,
                    sortOrder: currentSortOrder,
                    context: context,
                    isSearch: true,
                  ),
                );
              });
            },
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search...',
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: ColorCodes.whitecolor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text('No activities for today'),
        ],
      ),
    );
  }
}
