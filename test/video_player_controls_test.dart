import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/activity_details/activity_details.dart';
import 'package:mindfully_evolve_app/screens/activity_details/activity_bloc/post_activity_bloc.dart';
import 'package:mindfully_evolve_app/common/custom_videoplayer.dart';
// The fake implements the platform interface used by video_player.
// ignore: depend_on_referenced_packages
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FakeVideoPlatform extends VideoPlayerPlatform {
  FakeVideoPlatform({this.autoInitialize = true});
  final bool autoInitialize;
  final streams = <int, StreamController<VideoEvent>>{};
  final positions = <int, Duration>{};
  final playing = <int, bool>{};
  @override
  Future<void> init() async {}
  @override
  Future<int?> create(DataSource source) async {
    final id = streams.length;
    streams[id] = StreamController<VideoEvent>();
    if (autoInitialize) initializeVideo(id);
    return id;
  }

  void initializeVideo(int id) {
    streams[id]!.add(VideoEvent(
        eventType: VideoEventType.initialized,
        size: const Size(1600, 900),
        duration: const Duration(minutes: 10)));
  }

  @override
  Stream<VideoEvent> videoEventsFor(int id) => streams[id]!.stream;
  @override
  Future<void> dispose(int id) async {
    await streams[id]!.close();
  }

  @override
  Future<void> play(int id) async {
    playing[id] = true;
  }

  @override
  Future<void> pause(int id) async {
    playing[id] = false;
  }

  @override
  Future<Duration> getPosition(int id) async => positions[id] ?? Duration.zero;
  @override
  Future<void> seekTo(int id, Duration position) async {
    positions[id] = position;
  }

  @override
  Future<void> setLooping(int id, bool looping) async {}
  @override
  Future<void> setVolume(int id, double volume) async {}
  @override
  Future<void> setPlaybackSpeed(int id, double speed) async {}
  @override
  Widget buildView(int id) => const ColoredBox(color: Colors.black);
}

void main() {
  testWidgets('details appear before video loads and reuse its duration',
      (tester) async {
    final previous = VideoPlayerPlatform.instance;
    final platform = FakeVideoPlatform(autoInitialize: false);
    VideoPlayerPlatform.instance = platform;
    addTearDown(() => VideoPlayerPlatform.instance = previous);
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider(
        create: (_) => PostActivityBloc(),
        child: const ActivityDetailScreen(
          videoUrl: 'https://example.com/video.mp4',
          thumbnail: null,
          name: 'Finding calm',
          duration: '--:--',
          tags: [],
          description: 'Take a quiet moment',
          activityId: 'test',
          isFavorite: false,
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('Finding calm'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('10:00'), findsNothing);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
    expect(platform.streams.length, 1);

    platform.initializeVideo(0);
    await tester.pumpAndSettle();
    expect(find.text('10:00'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNotNull);
    expect(platform.streams.length, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets(
      'player has no time overlay and supports seeking and hidden controls',
      (tester) async {
    final previous = VideoPlayerPlatform.instance;
    final platform = FakeVideoPlatform();
    VideoPlayerPlatform.instance = platform;
    addTearDown(() => VideoPlayerPlatform.instance = previous);
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var progress = Duration.zero;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
      child: SizedBox(
          width: 320,
          height: 200,
          child: OnlineVideoPlayer(
            videoUrl: 'https://example.com/video.mp4',
            onProgress: (value) => progress = value,
          )),
    ))));
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsNothing);
    await tester.tap(find.byTooltip('Forward 10 seconds'));
    await tester.pump();
    expect(platform.positions[0], const Duration(seconds: 10));
    expect(progress, const Duration(seconds: 10));
    await tester.tap(find.byTooltip('Back 10 seconds'));
    await tester.pump();
    expect(platform.positions[0], Duration.zero);
    await tester.tap(find.byType(Slider));
    await tester.pump();
    expect(platform.positions[0]!.inSeconds, closeTo(300, 10));
    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    expect(platform.playing[0], isTrue);
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byTooltip('Pause').hitTestable(), findsNothing);
    await tester.tap(find.byType(OnlineVideoPlayer));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byTooltip('Pause').hitTestable(), findsOneWidget);
    await tester.tap(find.byTooltip('Pause'));
    await tester.pump(const Duration(seconds: 4));
    expect(platform.playing[0], isFalse);
    expect(find.byTooltip('Play').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
