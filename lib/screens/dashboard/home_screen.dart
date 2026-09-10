import 'home_dashboard.dart';
import 'home_model.dart';
import '../activity_listing/favourite_activities.dart';
import '../activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import '../feeling_category/feelingcategory_bloc/feeling_categories_bloc.dart';
import '../feeling_category/feelingcategory_bloc/feeling_categories_event.dart';
import '../feeling_category/feelingcategory_bloc/feeling_categories_state.dart';
import 'dashboard_bloc/recently_played_model.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/global.dart' as globals;
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
  const HomePage({super.key, this.onMeditate});
  final VoidCallback? onMeditate;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  String currentSortOrder = 'desc';
  Timer? _debounce;

  // Create the bloc once, outside of build, so it isn't recreated on every rebuild
  late HomePageBloc _homePageBloc;

  @override
  void initState() {
    super.initState();
    _homePageBloc = HomePageBloc()
      ..add(FetchHomePageDataEvent(context: context));
    context.read<SubscriptionBloc>().add(FetchBillingHistory());
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
      debugPrint("Unable to read the video duration.");
      return "--:--";
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

  Future<void> _openPage(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (!mounted) return;
    _homePageBloc.add(FetchHomePageDataEvent(context: context, isSearch: true));
  }

  Future<void> _showMood() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => BlocProvider(
        create: (_) => CategoryBloc(),
        child: BlocConsumer<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategorySuccess) Navigator.pop(context);
          },
          builder: (context, state) => SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('How are you feeling today?',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 20),
                    if (state is CategoryFailure)
                      Text(state.error,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    if (state is CategoryLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Wrap(spacing: 10, runSpacing: 10, children: [
                        for (final mood in [
                          'Grounded',
                          'Aligned',
                          'Calm',
                          'Steady',
                          'Connected'
                        ])
                          ActionChip(
                              label: Text(mood),
                              onPressed: () => context
                                  .read<CategoryBloc>()
                                  .add(SelectCategory(mood: mood))),
                      ]),
                  ]),
            ),
          ),
        ),
      ),
    );
    if (mounted) {
      _homePageBloc
          .add(FetchHomePageDataEvent(context: context, isSearch: true));
    }
  }

  Future<void> _openRecent(RecentlyPlayedActivity item) => _openVideo(
        id: item.id,
        name: item.name,
        description: item.description,
        thumbnail: item.thumbnail,
        video: item.video,
        tags: item.tagNames,
        isFavorite: item.isFavorite,
        duration: item.totalVideoTime,
      );

  Future<void> _openActivity(ActivityData item) async {
    if (item.categoryName == 'Daily Pause' ||
        item.video == null ||
        item.video!.isEmpty) {
      final key = GlobalKey();
      await showDialog<void>(
          context: context,
          builder: (dialogContext) => Dialog(
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    IconButton(
                        tooltip: 'Share',
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () async {
                          final file = await captureWidget(key, 'daily-pause');
                          if (file != null && dialogContext.mounted) {
                            ShareUtils.showShareOptionsWithImage(
                                dialogContext, file);
                          }
                        }),
                    IconButton(
                        tooltip: 'Close',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(dialogContext)),
                  ]),
                  RepaintBoundary(
                      key: key,
                      child: Image.network(
                          HomeDashboard.imageUrl(item.thumbnail),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text('This image couldn’t load.')))),
                ])),
              ));
      return;
    }
    await _openVideo(
        id: item.id,
        name: item.name,
        description: item.description,
        thumbnail: item.thumbnail,
        video: item.video!,
        tags: item.tagName ?? [],
        isFavorite: item.isFavorite);
  }

  Future<void> _openVideo(
      {required String id,
      required String name,
      required String description,
      required String thumbnail,
      required String video,
      required List<String> tags,
      required bool isFavorite,
      String? duration}) async {
    Uint8List bytes = Uint8List(0);
    try {
      bytes = await fetchImageBytes(HomeDashboard.imageUrl(thumbnail));
    } catch (_) {}
    final videoUrl = HomeDashboard.imageUrl(video);
    final length = duration ?? await _getVideoDuration(videoUrl);
    if (!mounted) return;
    await _openPage(MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => PostActivityBloc()),
          BlocProvider(create: (_) => ActivityBloc()),
        ],
        child: ActivityDetailScreen(
            videoUrl: videoUrl,
            thumbnail: bytes,
            name: name,
            duration: length,
            tags: tags,
            description: description,
            activityId: id,
            isFavorite: isFavorite)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    return HomeDashboard(
                      state: state,
                      onProfile: () => _openPage(const UserprofileScreen()),
                      onSearch: () => widget.onMeditate?.call(),
                      onMeditate: () => widget.onMeditate?.call(),
                      onMood: _showMood,
                      onFavorites: () => _openPage(const FavouriteActivity()),
                      onRecent: () => _openPage(RecentActivity(
                          recentlyPlayedActivities: state.recentlyPlayedData)),
                      onNotifications: () => _openPage(BlocProvider.value(
                          value: context.read<NotificationBloc>(),
                          child: NotificatonScreen())),
                      onActivity: _openActivity,
                      onResume: _openRecent,
                      onCategory: (name) {
                        final items = state.homePageData.data[name]?.activities;
                        if (items == null || items.isEmpty) return;
                        _openPage(BlocProvider(
                            create: (_) => ActivityBloc(),
                            child: name == 'Daily Anchor'
                                ? MeditationListingDaily(
                                    categoryId: items.first.categoryId)
                                : MeditationListing(
                                    categoryId: items.first.categoryId)));
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
