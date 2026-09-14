import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindfully_evolve_app/utils/color_constants.dart';
import 'package:video_player/video_player.dart';

class OnlineVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final Uint8List? thumbnail;
  final bool isFullscreen;
  final Duration initialPosition;
  final Function(Duration)? onProgress;

  const OnlineVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnail,
    this.isFullscreen = false,
    this.initialPosition = Duration.zero,
    this.onProgress,
  });

  @override
  _OnlineVideoPlayerState createState() => _OnlineVideoPlayerState();
}

class _OnlineVideoPlayerState extends State<OnlineVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _scrubbing = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) async {
      if (!mounted) return;
      setState(() {});
      if (widget.initialPosition > Duration.zero) {
        await _controller.seekTo(widget.initialPosition);
      }
      if (!mounted) return;
      _controller.setLooping(true);
      _controller.addListener(() {
        if (widget.onProgress != null) {
          widget.onProgress!(_controller.value.position);
        }
      });
    });
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleHide() {
    _hideControlsTimer?.cancel();
    if (!_controller.value.isPlaying ||
        _scrubbing ||
        MediaQuery.accessibleNavigationOf(context)) return;
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _togglePlayPause() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
    setState(() => _showControls = true);
    _scheduleHide();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _scheduleHide();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _seekRelative(Duration offset) {
    final newPosition = _controller.value.position + offset;
    final duration = _controller.value.duration;
    _scheduleHide();
    _controller.seekTo(newPosition < Duration.zero
        ? Duration.zero
        : (newPosition > duration ? duration : newPosition));
  }

  void _toggleFullscreen() async {
    _hideControlsTimer?.cancel();
    _controller.pause();

    final position = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoScreen(
          videoUrl: widget.videoUrl,
          thumbnail: widget.thumbnail,
          initialPosition: _controller.value.position,
          aspectRatio: _controller.value.aspectRatio,
        ),
      ),
    );

    if (!mounted) return;
    if (position != null && position is Duration) {
      await _controller.seekTo(position);
      _controller.play();
    } else {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller.value.isInitialized) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleControls,
            child: Center(
                child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(widget.isFullscreen ? 0 : 20),
                child: Stack(alignment: Alignment.center, children: [
                  VideoPlayer(_controller),
                  Positioned.fill(
                      child: IgnorePointer(
                    ignoring: !_showControls,
                    child: AnimatedOpacity(
                      opacity: _showControls ? 1 : 0,
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      child: ExcludeSemantics(
                        excluding: !_showControls,
                        child: Stack(alignment: Alignment.center, children: [
                          const Positioned.fill(
                              child: IgnorePointer(
                            child: DecoratedBox(
                                decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black26,
                                  Colors.transparent,
                                  Colors.black54
                                ],
                              ),
                            )),
                          )),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            _control(
                                tooltip: 'Back 10 seconds',
                                icon: Icons.replay_10_rounded,
                                onPressed: () => _seekRelative(
                                    const Duration(seconds: -10))),
                            const SizedBox(width: 16),
                            ValueListenableBuilder<VideoPlayerValue>(
                              valueListenable: _controller,
                              builder: (context, value, _) => IconButton.filled(
                                tooltip: value.isPlaying ? 'Pause' : 'Play',
                                style: IconButton.styleFrom(
                                  backgroundColor: ColorCodes.cream,
                                  foregroundColor: ColorCodes.charcoal,
                                  minimumSize: const Size.square(56),
                                ),
                                iconSize: 32,
                                icon: Icon(value.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded),
                                onPressed: _togglePlayPause,
                              ),
                            ),
                            const SizedBox(width: 16),
                            _control(
                                tooltip: 'Forward 10 seconds',
                                icon: Icons.forward_10_rounded,
                                onPressed: () =>
                                    _seekRelative(const Duration(seconds: 10))),
                          ]),
                          if (!widget.isFullscreen)
                            Positioned(
                                top: 4,
                                right: 4,
                                child: _control(
                                  tooltip: 'Full screen',
                                  icon: Icons.fullscreen_rounded,
                                  onPressed: _toggleFullscreen,
                                )),
                          Positioned(
                              bottom: 0,
                              left: 12,
                              right: 12,
                              child: _CustomVideoProgressBar(
                                controller: _controller,
                                onScrubbingChanged: (scrubbing) {
                                  _scrubbing = scrubbing;
                                  _scheduleHide();
                                },
                              )),
                        ]),
                      ),
                    ),
                  )),
                ]),
              ),
            )),
          );
        } else if (snapshot.hasError) {
          return const ColoredBox(
            color: Color(0xFF211F1C),
            child: Center(
                child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.videocam_off_outlined,
                    color: Colors.white70, size: 32),
                SizedBox(height: 12),
                Text('Video unavailable',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 6),
                Text('Please check your connection and reopen this practice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            )),
          );
        } else {
          return Stack(fit: StackFit.expand, children: [
            if (widget.thumbnail != null && widget.thumbnail!.isNotEmpty)
              Image.memory(widget.thumbnail!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            const ColoredBox(color: Colors.black54),
            const Center(
                child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                    semanticsLabel: 'Loading meditation video')),
          ]);
        }
      },
    );
  }

  Widget _control(
          {required String tooltip,
          required IconData icon,
          required VoidCallback onPressed}) =>
      IconButton(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: ColorCodes.charcoal.withValues(alpha: .85),
          foregroundColor: ColorCodes.cream,
          minimumSize: const Size.square(48),
        ),
        icon: Icon(icon, size: 24),
        onPressed: onPressed,
      );
}

class FullscreenVideoScreen extends StatefulWidget {
  final String videoUrl;
  final Uint8List? thumbnail;
  final Duration initialPosition;
  final double aspectRatio;

  const FullscreenVideoScreen({
    super.key,
    required this.videoUrl,
    this.thumbnail,
    this.initialPosition = Duration.zero,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<FullscreenVideoScreen> createState() => _FullscreenVideoScreenState();
}

class _FullscreenVideoScreenState extends State<FullscreenVideoScreen> {
  final GlobalKey<_OnlineVideoPlayerState> _playerKey =
      GlobalKey<_OnlineVideoPlayerState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Duration _getCurrentPosition() {
    if (_playerKey.currentState != null) {
      return _playerKey.currentState!._controller.value.position;
    }
    return Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: OnlineVideoPlayer(
                key: _playerKey,
                videoUrl: widget.videoUrl,
                thumbnail: widget.thumbnail,
                isFullscreen: true,
                initialPosition: widget.initialPosition,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.fullscreen_exit,
                  color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context, _getCurrentPosition()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomVideoProgressBar extends StatefulWidget {
  const _CustomVideoProgressBar(
      {required this.controller, required this.onScrubbingChanged});
  final VideoPlayerController controller;
  final ValueChanged<bool> onScrubbingChanged;

  @override
  State<_CustomVideoProgressBar> createState() =>
      _CustomVideoProgressBarState();
}

class _CustomVideoProgressBarState extends State<_CustomVideoProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: widget.controller,
        builder: (context, value, _) {
          final duration = value.duration.inMilliseconds;
          final progress = duration > 0
              ? (value.position.inMilliseconds / duration).clamp(0.0, 1.0)
              : 0.0;
          return Semantics(
            label: 'Video progress',
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: ColorCodes.cream,
                inactiveTrackColor: ColorCodes.cream.withValues(alpha: .35),
                thumbColor: ColorCodes.cream,
                overlayColor: ColorCodes.cream.withValues(alpha: .15),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: _dragValue ?? progress,
                semanticFormatterCallback: (value) =>
                    '${(value * 100).round()} percent',
                onChangeStart: duration <= 0
                    ? null
                    : (value) {
                        setState(() => _dragValue = value);
                        widget.onScrubbingChanged(true);
                      },
                onChanged: duration <= 0
                    ? null
                    : (value) => setState(() => _dragValue = value),
                onChangeEnd: duration <= 0
                    ? null
                    : (value) {
                        widget.controller.seekTo(
                            Duration(milliseconds: (duration * value).round()));
                        setState(() => _dragValue = null);
                        widget.onScrubbingChanged(false);
                      },
              ),
            ),
          );
        },
      );
}
