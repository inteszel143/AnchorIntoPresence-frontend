import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/share_options.dart';
import '../../utils/urls.dart';
import 'loading_skeleton.dart';

Future<void> showDailyPausePreview(
  BuildContext context, {
  required String title,
  required String thumbnail,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxWidth: 640,
        maxHeight: MediaQuery.sizeOf(context).height * .9,
      ),
      builder: (_) => DailyPausePreview(title: title, thumbnail: thumbnail),
    );

class DailyPausePreview extends StatefulWidget {
  const DailyPausePreview(
      {super.key, required this.title, required this.thumbnail});
  final String title, thumbnail;
  @override
  State<DailyPausePreview> createState() => _DailyPausePreviewState();
}

class _DailyPausePreviewState extends State<DailyPausePreview> {
  final _imageKey = GlobalKey();
  bool _sharing = false;
  bool _imageReady = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    ui.Image? image;
    try {
      final boundary =
          _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      image = await boundary.toImage(
          pixelRatio: MediaQuery.devicePixelRatioOf(context));
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = await getTemporaryDirectory();
      final file = File(
          '${directory.path}/pause-${DateTime.now().microsecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      if (mounted) {
        ShareUtils.showShareOptionsWithImage(context, XFile(file.path));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Couldn’t share this image. Please try again.')));
      }
    } finally {
      image?.dispose();
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final url = Uri.tryParse(widget.thumbnail)?.hasScheme == true
        ? widget.thumbnail
        : '${Urls.baseUrlimages}${widget.thumbnail}';
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 16, 16),
            child: Row(children: [
              Expanded(
                  child: Text('Daily Pause',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ))),
              IconButton.filledTonal(
                tooltip: 'Close preview',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ]),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: RepaintBoundary(
                      key: _imageKey,
                      child: Image.network(
                        url,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        semanticLabel: widget.title,
                        frameBuilder: (context, child, frame, synchronous) {
                          final loaded = frame != null || synchronous;
                          if (!_imageReady && loaded) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) setState(() => _imageReady = true);
                            });
                          }
                          return loaded
                              ? child
                              : const AspectRatio(
                                  aspectRatio: 1,
                                  child: LoadingSkeleton(
                                    label: 'Loading reflection',
                                    child: SkeletonBlock(
                                        height: double.infinity, radius: 20),
                                  ),
                                );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.all(32),
                          color: colors.surfaceContainerHighest,
                          child: Column(children: [
                            Icon(Icons.image_not_supported_outlined,
                                size: 36, color: colors.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                                'This reflection couldn’t load. Please reopen it to try again.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Carry this with you',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant, height: 1.5)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: FilledButton.icon(
              onPressed: _imageReady && !_sharing ? _share : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.ios_share_rounded, size: 20),
              label: Text(_sharing ? 'Preparing image…' : 'Share this pause',
                  textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
