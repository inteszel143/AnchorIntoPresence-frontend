// Opt-in marketing capture harness. Production widgets remain unchanged.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import 'package:mindfully_evolve_app/common/widgets/app_tab_bar.dart';
import 'package:mindfully_evolve_app/screens/dashboard/home_dashboard.dart';
import 'package:mindfully_evolve_app/screens/dashboard/home_model.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_bloc.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_state.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/recently_played_model.dart';
import 'package:mindfully_evolve_app/screens/meditate/meditate_screen.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_model.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_state.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/recent_activity.dart';
import 'package:mindfully_evolve_app/screens/track/track_screen.dart';
import 'package:mindfully_evolve_app/screens/track/track_model.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_bloc.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_state.dart';
import 'package:mindfully_evolve_app/screens/community/community_screen.dart';
import 'package:mindfully_evolve_app/screens/community/community_model.dart';
import 'package:mindfully_evolve_app/screens/community/community_bloc/community_state.dart';
import 'package:mindfully_evolve_app/screens/profile/profile_screen.dart';
import 'package:mindfully_evolve_app/screens/welcome/illustrated_welcome_screen.dart';
import '../video_player_controls_test.dart' show FakeVideoPlatform;

const handheld = bool.fromEnvironment('HANDHELD_STORE');
const output =
    handheld ? '../output/app-store-handheld' : '../output/app-store';
late Uint8List handArtwork;
const cream = Color(0xFFF5F0E7);
const ink = Color(0xFF373C35);

class AssetHttp extends HttpOverrides {
  AssetHttp(this.bytes);
  final Uint8List bytes;
  @override
  HttpClient createHttpClient(SecurityContext? context) => AssetClient(bytes);
}

class AssetClient implements HttpClient {
  AssetClient(this.bytes);
  final Uint8List bytes;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => AssetRequest(bytes);
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      AssetRequest(bytes);
  @override
  void close({bool force = false}) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class AssetHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class AssetRequest implements HttpClientRequest {
  AssetRequest(this.bytes);
  final Uint8List bytes;
  @override
  HttpHeaders get headers => AssetHeaders();
  @override
  Future<HttpClientResponse> close() async => AssetResponse(bytes);
  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await stream.drain<void>();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class AssetResponse extends Stream<List<int>> implements HttpClientResponse {
  AssetResponse(this.bytes);
  final Uint8List bytes;
  @override
  int get statusCode => 200;
  @override
  int get contentLength => bytes.length;
  @override
  HttpHeaders get headers => AssetHeaders();
  @override
  bool get isRedirect => false;
  @override
  String get reasonPhrase => 'OK';
  @override
  bool get persistentConnection => false;
  @override
  List<RedirectInfo> get redirects => [];
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      Stream<List<int>>.value(bytes).listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final recent = [
  for (final name in [
    'A gentle beginning',
    'Return to your breath',
    'A moment of stillness'
  ])
    RecentlyPlayedActivity(
        id: name,
        videoTimestamp: '03:20',
        totalVideoTime: '10:00',
        isCompleted: false,
        name: name,
        thumbnail: 'store-art.png',
        video: '',
        description: 'Make a little room for yourself.',
        duration: '10:00',
        tags: [],
        isFavorite: true),
];
final home = HomePageLoadedState(
    profileData: ProfileDataModel(
        id: 'sample',
        name: 'Luciana',
        email: 'sample@example.com',
        isVerified: true,
        isBlocked: false,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        resetPassword: false),
    homePageData: HomePageDataModel(message: '', status: true, data: {
      for (final category in ['Daily Anchor', 'Daily Pause'])
        category: CategoryData(activities: [
          ActivityData(
              id: category,
              categoryId: category,
              name: category == 'Daily Anchor'
                  ? 'A gentle beginning'
                  : 'Return to this moment',
              thumbnail: 'store-art.png',
              description: '',
              categoryName: category,
              isFavorite: false)
        ]),
    }),
    recentlyPlayedData: recent);

class StoreHome extends HomePageBloc {
  StoreHome() {
    emit(home);
  }
}

final summary = UserActivitySummary.fromJson({
  'message': '',
  'status': true,
  'data': {
    'loggedActivities': {'totalTime': '04:20', 'thumbnails': []},
    'categoryDistribution': {},
    'loginDates': {
      'streak': [
        {
          'loginDates': [
            for (final day in [
              2,
              3,
              4,
              7,
              8,
              9,
              10,
              14,
              15,
              16,
              17,
              18,
              21,
              22,
              23,
              24,
              25,
              26,
              27
            ])
              '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}'
          ]
        }
      ]
    }
  },
});

class StoreTrack extends TrackBloc {
  StoreTrack() {
    emit(TrackLoadedState(summary));
  }
}

class StoreLibrary extends ActivityBloc {
  StoreLibrary() {
    emit(ActivityLoaded(ActivityResponse(
        message: '',
        status: true,
        recommendedActivities: [],
        activities: [
          for (var i = 0; i < 3; i++)
            Activity(
                id: '$i',
                name: [
                  'A gentle beginning',
                  'Return to your breath',
                  'A moment of stillness'
                ][i],
                description: 'Make a little room for yourself.',
                thumbnail: 'store-art.png',
                video: 'https://example.com/sample.mp4',
                isFavorite: i != 0,
                tags: [i == 0 ? 'Calm' : 'Breath']),
        ])));
  }
}

Widget tab(Widget child, int index) => AppScaffold(
    extendBody: true,
    body: child,
    bottomNavigationBar: AppTabBar(selectedIndex: index, onTap: (_) {}));
Widget homeWidget() => tab(
    SafeArea(
        child: HomeDashboard(
            state: home,
            onProfile: () {},
            onSearch: () {},
            onRecent: () {},
            onNotifications: () {},
            onActivity: (_) {},
            onCategory: (_) {},
            onResume: (_) {})),
    0);
Widget library() => tab(
    BlocProvider<ActivityBloc>(
        create: (_) => StoreLibrary(), child: const MeditationLibrary()),
    1);
Widget profile() => MultiBlocProvider(providers: [
      BlocProvider<HomePageBloc>(create: (_) => StoreHome()),
      BlocProvider<TrackBloc>(create: (_) => StoreTrack()),
    ], child: const ProfileScreen());
Widget community() => tab(
    CommunityFeed(
        state: CommunityLoaded(posts: [
      for (var i = 0; i < 3; i++)
        Post(
            id: '$i',
            shareId: '',
            userId: '$i',
            userName: ['Sophie', 'James', 'Maya'][i],
            message: [
              'Today I took ten minutes just for myself. A small pause, but it changed how I met the rest of my day.',
              'A reminder I needed: you can begin again, as many times as you need.',
              'What is one small thing you are grateful for today?'
            ][i],
            postType: '',
            images: [],
            postAnonymously: false,
            liked: i == 0,
            likesCount: [12, 8, 5][i],
            commentsCount: [3, 2, 1][i],
            sharesCount: 0,
            createdAt: DateTime.now().subtract(Duration(hours: i + 1))),
    ])),
    2);

const captions = [
  (
    '01-daily-practice',
    'A little presence.\nEvery day.',
    'Your daily anchor, your moment to pause.'
  ),
  (
    '02-meditate',
    'Make room\nfor yourself.',
    'Explore guided meditations at your pace.'
  ),
  (
    '03-favorites',
    'Keep what\nbrings you back.',
    'Your favorite practices, easy to find.'
  ),
  (
    '04-recent',
    'Pick up your\nmoment of calm.',
    'Return to the practices you have played.'
  ),
  (
    '05-track',
    'Small moments.\nA growing practice.',
    'See the time you have made for yourself.'
  ),
  (
    '06-community',
    'Find connection\nin the everyday.',
    'Share a reflection. Be part of a community.'
  ),
  (
    '07-profile',
    'Your journey,\nat a glance.',
    'A personal view of your time and consistency.'
  ),
  ('08-welcome', 'Come back\nto yourself.', 'Begin with Anchor into Presence.'),
];

Widget handheldPoster(int index, Uint8List screenshot) {
  final bottomTitle = index.isOdd;
  final artWidth = bottomTitle ? 606.0 : 640.0;
  return ColoredBox(
      color: cream,
      child: Stack(children: [
        Positioned(
          left: (440 - artWidth) / 2,
          top: bottomTitle ? -25 : 172,
          width: artWidth,
          height: artWidth * 1.5,
          child: FittedBox(
              child: SizedBox(
                  width: 1024,
                  height: 1536,
                  child: Stack(children: [
                    Positioned.fill(child: Image.memory(handArtwork)),
                    Positioned(
                        left: 269,
                        top: 105,
                        width: 488,
                        height: 1072,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(58),
                            child: Image.memory(screenshot,
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.high))),
                  ]))),
        ),
        if (bottomTitle)
          const Positioned(
              left: 0,
              right: 0,
              top: 670,
              bottom: 0,
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0, .31, 1],
                          colors: [Color(0x00F5F0E7), cream, cream])))),
        Positioned(
            left: 28,
            right: 28,
            top: bottomTitle ? 760 : 32,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('ANCHOR INTO PRESENCE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.3,
                          color: ink)),
                  const SizedBox(height: 16),
                  Text(captions[index].$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 37,
                          letterSpacing: -1.6,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                          color: ink)),
                  const SizedBox(height: 12),
                  Text(captions[index].$3,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, height: 1.4, color: ink)),
                ])),
      ]));
}

Widget poster(int index, Uint8List screenshot) {
  if (handheld) return handheldPoster(index, screenshot);
  const fg = ink;
  return ColoredBox(
      color: cream,
      child: Stack(children: [
        Positioned(
            right: -160,
            top: 390,
            child: Container(
                width: 580,
                height: 580,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: fg.withValues(alpha: .09), width: 1)))),
        Positioned(
            left: -200,
            top: 330,
            child: Container(
                width: 590,
                height: 590,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: fg.withValues(alpha: .09), width: 1)))),
        Positioned(
            top: 32,
            left: 28,
            right: 28,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ANCHOR INTO PRESENCE',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.3,
                      color: fg)),
              const SizedBox(height: 22),
              Text(captions[index].$2,
                  style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 39,
                      letterSpacing: -1.8,
                      fontWeight: FontWeight.w600,
                      height: 1.12,
                      color: fg)),
              const SizedBox(height: 14),
              Text(captions[index].$3,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: fg.withValues(alpha: .85))),
            ])),
        Positioned(
            top: 236,
            left: 48,
            width: 344,
            height: 704,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: const Color(0xFF292B28),
                  borderRadius: BorderRadius.circular(42),
                  border: Border.all(color: const Color(0xFF7D8079), width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: .17),
                        blurRadius: 30,
                        offset: const Offset(0, 14))
                  ]),
              child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Image.memory(screenshot,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high))),
            )),
      ]));
}

Future<Uint8List> save(
    WidgetTester tester, GlobalKey key, String path, double ratio) async {
  late Uint8List bytes;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: ratio);
    bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
    await File(path).writeAsBytes(bytes);
    image.dispose();
  });
  return bytes;
}

void main() {
  testWidgets('export eight App Store screenshots from production screens',
      (tester) async {
    if (!const bool.fromEnvironment('CAPTURE_STORE')) return;
    if (handheld) {
      handArtwork = File('$output/assets/hand-phone.png').readAsBytesSync();
    }
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final originalHttp = HttpOverrides.current;
    final originalVideo = VideoPlayerPlatform.instance;
    final art = await rootBundle
        .load('assets/images/onboarding/onboarding-mandala-subtle-light.png');
    HttpOverrides.global = AssetHttp(art.buffer.asUint8List());
    VideoPlayerPlatform.instance = FakeVideoPlatform();
    addTearDown(() {
      HttpOverrides.global = originalHttp;
      VideoPlayerPlatform.instance = originalVideo;
    });
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final font in [
      ('DM Sans', 'assets/fonts/DMSans/DMSans-Variable.ttf'),
      ('Manrope', 'assets/fonts/Manrope/Manrope-Variable.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await tester.runAsync(
          (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load);
    }
    final posters = <Uint8List>[];
    for (var i = 0; i < 8; i++) {
      tester.view.physicalSize = Size(430, handheld ? 944 : 896);
      final key = GlobalKey();
      final page = switch (i) {
        0 => homeWidget(),
        1 || 2 => library(),
        3 => RecentActivity(recentlyPlayedActivities: recent),
        4 => tab(TrackOverview(state: TrackLoadedState(summary)), 3),
        5 => community(),
        6 => profile(),
        _ => const IllustratedWelcomeScreen(),
      };
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: RepaintBoundary(
            key: key,
            child: MediaQuery(
                data: MediaQueryData(
                    size: Size(430, handheld ? 944 : 896),
                    padding: EdgeInsets.only(top: 44, bottom: 24)),
                child: Stack(children: [
                  Positioned.fill(child: page),
                  const Positioned(
                      top: 12,
                      left: 28,
                      child: Text('9:41',
                          style: TextStyle(
                              inherit: false,
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ink))),
                  const Positioned(
                      top: 12,
                      right: 24,
                      child: Row(children: [
                        Icon(Icons.signal_cellular_alt, size: 15, color: ink),
                        SizedBox(width: 4),
                        Icon(Icons.wifi, size: 15, color: ink),
                        SizedBox(width: 4),
                        Icon(Icons.battery_full, size: 15, color: ink)
                      ])),
                ])),
          )));
      await tester.runAsync(() async {
        await precacheImage(
            const AssetImage('assets/images/app-background-light.png'),
            key.currentContext!);
        await precacheImage(
            const AssetImage(
                'assets/images/onboarding/onboarding-mandala-subtle-light.png'),
            key.currentContext!);
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
      if (i == 2) {
        await tester.tap(find.text('Favorites'));
        await tester.pumpAndSettle();
      }
      final images = tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => image.image)
          .toList();
      await tester.runAsync(() async {
        for (final provider in images) {
          await precacheImage(provider, key.currentContext!);
        }
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final raw =
          await save(tester, key, '$output/raw/${captions[i].$1}.png', 3);
      await tester.pumpWidget(const SizedBox());
      tester.view.physicalSize = const Size(440, 956);
      final posterKey = GlobalKey();
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: RepaintBoundary(
              key: posterKey,
              child: DefaultTextStyle(
                  style: const TextStyle(
                      fontFamily: 'DM Sans', decoration: TextDecoration.none),
                  child: poster(i, raw)))));
      await tester.runAsync(() async {
        await precacheImage(MemoryImage(raw), posterKey.currentContext!);
        if (handheld)
          await precacheImage(
              MemoryImage(handArtwork), posterKey.currentContext!);
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      posters.add(await save(
          tester, posterKey, '$output/screenshots/${captions[i].$1}.png', 3));
      await tester.pumpWidget(const SizedBox());
    }
    tester.view.physicalSize = const Size(960, 1080);
    final sheetKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
        home: RepaintBoundary(
            key: sheetKey,
            child: ColoredBox(
                color: cream,
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      const SizedBox(height: 12),
                      const Text('ANCHOR INTO PRESENCE  /  APP STORE',
                          style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 20,
                              color: ink,
                              decoration: TextDecoration.none)),
                      const SizedBox(height: 24),
                      Expanded(
                          child: GridView.count(
                              crossAxisCount: 4,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 440 / 956,
                              children: [
                            for (final bytes in posters) Image.memory(bytes)
                          ])),
                    ]))))));
    await tester.runAsync(() async {
      for (final bytes in posters) {
        await precacheImage(MemoryImage(bytes), sheetKey.currentContext!);
      }
    });
    await tester.pumpAndSettle();
    await save(tester, sheetKey, '$output/contact-sheet.png', 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
