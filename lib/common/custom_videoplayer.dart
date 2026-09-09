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
    Key? key,
    required this.videoUrl,
    this.thumbnail,
    this.isFullscreen = false,
    this.initialPosition = Duration.zero,
    this.onProgress,
  }) : super(key: key);

  @override
  _OnlineVideoPlayerState createState() => _OnlineVideoPlayerState();
}

class _OnlineVideoPlayerState extends State<OnlineVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) async {
      setState(() {});
      if (widget.initialPosition > Duration.zero) {
        await _controller.seekTo(widget.initialPosition);
      }
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
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
      _showControls = true;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _seekRelative(Duration offset) {
    final newPosition = _controller.value.position + offset;
    final duration = _controller.value.duration;
    _controller.seekTo(newPosition < Duration.zero
        ? Duration.zero
        : (newPosition > duration ? duration : newPosition));
  }

  void _toggleFullscreen() async {
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

    if (position != null && position is Duration) {
      await _controller.seekTo(position);
      _controller.play();
    } else {
      _controller.play();
    }
  }

  // Formats a Duration as "m:ss" (or "h:mm:ss" once the video is an hour
  // or longer) for the played/total label above the progress bar.
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller.value.isInitialized) {
          return GestureDetector(
            onTap: _toggleControls,
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video fills the AspectRatio box exactly
                      VideoPlayer(_controller),

                      // Played / total duration label — sits just above the
                      // progress bar, centered.
                      if (_showControls)
                        Positioned(
                          bottom: 14,
                          left: 16,
                          right: 16,
                          child: ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: _controller,
                            builder: (context, value, child) {
                              final position = _isDraggingProgress
                                  ? _draggingPosition
                                  : value.position;
                              return Text(
                                '${_formatDuration(position)} / ${_formatDuration(value.duration)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: ColorCodes.whitecolor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      // Progress bar — always inside the video box
                      if (_showControls)
                        Positioned(
                          bottom: 4,
                          left: 16,
                          right: 16,
                          child: _CustomVideoProgressBar(
                            controller: _controller,
                            onDragPositionChanged: (dragging, position) {
                              setState(() {
                                _isDraggingProgress = dragging;
                                _draggingPosition = position;
                              });
                            },
                          ),
                        ),

                      // Play/pause + seek controls
                      if (_showControls)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              iconSize: 36,
                              color: ColorCodes.whitecolor,
                              icon: const Icon(Icons.replay_10),
                              onPressed: () =>
                                  _seekRelative(const Duration(seconds: -10)),
                            ),
                            IconButton(
                              iconSize: 64,
                              color: ColorCodes.whitecolor,
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                              ),
                              onPressed: _togglePlayPause,
                            ),
                            IconButton(
                              iconSize: 36,
                              color: ColorCodes.whitecolor,
                              icon: const Icon(Icons.forward_10),
                              onPressed: () =>
                                  _seekRelative(const Duration(seconds: 10)),
                            ),
                          ],
                        ),

                      // Fullscreen button — always top-right inside video
                      if (_showControls && !widget.isFullscreen)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(
                              Icons.fullscreen,
                              color: ColorCodes.whitecolor,
                              size: 28,
                            ),
                            onPressed: _toggleFullscreen,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading video'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // Tracked so the label shows the position being dragged to, not the
  // stale controller position, while the user is scrubbing.
  bool _isDraggingProgress = false;
  Duration _draggingPosition = Duration.zero;
}

class FullscreenVideoScreen extends StatefulWidget {
  final String videoUrl;
  final Uint8List? thumbnail;
  final Duration initialPosition;
  final double aspectRatio;

  const FullscreenVideoScreen({
    Key? key,
    required this.videoUrl,
    this.thumbnail,
    this.initialPosition = Duration.zero,
    this.aspectRatio = 16 / 9,
  }) : super(key: key);

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
  final VideoPlayerController controller;
  final void Function(bool isDragging, Duration position)?
      onDragPositionChanged;

  const _CustomVideoProgressBar({
    Key? key,
    required this.controller,
    this.onDragPositionChanged,
  }) : super(key: key);

  @override
  State<_CustomVideoProgressBar> createState() =>
      _CustomVideoProgressBarState();
}

class _CustomVideoProgressBarState extends State<_CustomVideoProgressBar> {
  late VideoPlayerController _controller;
  bool _isDragging = false;
  double _dragValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_update);
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (!_isDragging) {
      setState(() {});
    }
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final boxWidth = constraints.maxWidth;
    final dx = details.localPosition.dx.clamp(0, boxWidth);
    final relative = dx / boxWidth;
    setState(() {
      _dragValue = relative;
    });
    final duration = _controller.value.duration;
    widget.onDragPositionChanged?.call(true, duration * relative);
  }

  void _onDragEnd(DragEndDetails details) {
    final duration = _controller.value.duration;
    final position = duration * _dragValue;
    _controller.seekTo(position);
    setState(() {
      _isDragging = false;
    });
    widget.onDragPositionChanged?.call(false, position);
  }

  @override
  Widget build(BuildContext context) {
    final duration = _controller.value.duration.inMilliseconds;
    final position = _isDragging
        ? (_dragValue * duration).toInt()
        : _controller.value.position.inMilliseconds;

    final progress = duration > 0 ? position / duration : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const height = 8.0;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: (details) =>
              _onDragUpdate(details, constraints),
          onHorizontalDragEnd: _onDragEnd,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.transparent,
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
