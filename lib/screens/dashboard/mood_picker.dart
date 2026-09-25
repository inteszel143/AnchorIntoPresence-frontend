import 'package:flutter/material.dart';
import 'package:mindfully_evolve_app/utils/color_constants.dart';

const moodOptions = [
  ('Grounded', '😌', ColorCodes.cream),
  ('Aligned', '😊', ColorCodes.sand),
  ('Calm', '☺️', ColorCodes.sand),
  ('Steady', '🙂', ColorCodes.taupe),
  ('Connected', '🥰', ColorCodes.clay),
];

(String, String, Color)? moodOptionFor(String? value) {
  for (final mood in moodOptions) {
    if (mood.$1.toLowerCase() == value?.trim().toLowerCase()) return mood;
  }
  return null;
}

/// A mood selection stays local until the user confirms it.
class MoodPicker extends StatefulWidget {
  const MoodPicker({
    super.key,
    required this.onConfirm,
    this.isSaving = false,
    this.error,
    this.initialMood,
  });

  final ValueChanged<String> onConfirm;
  final bool isSaving;
  final String? error;
  final String? initialMood;

  @override
  State<MoodPicker> createState() => _MoodPickerState();
}

class _MoodPickerState extends State<MoodPicker> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    final index = moodOptions.indexWhere((mood) =>
        mood.$1.toLowerCase() == widget.initialMood?.trim().toLowerCase());
    _selected = index < 0 ? 2 : index;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('How are you feeling today?',
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Take a moment to check in with yourself. Choose the emoji that feels most like you.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            LayoutBuilder(builder: (context, constraints) {
              final itemWidth =
                  (constraints.maxWidth / moodOptions.length).clamp(56.0, 80.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(moodOptions.length, (index) {
                    final mood = moodOptions[index];
                    final selected = index == _selected;
                    return SizedBox(
                      width: itemWidth,
                      height: 92,
                      child: Center(
                        child: Semantics(
                          label: mood.$1,
                          button: true,
                          selected: selected,
                          enabled: !widget.isSaving,
                          child: Tooltip(
                            message: mood.$1,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              width: selected ? itemWidth : 48,
                              height: selected ? itemWidth : 48,
                              decoration: BoxDecoration(
                                color: selected
                                    ? mood.$3
                                    : colors.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: widget.isSaving
                                      ? null
                                      : () => setState(() => _selected = index),
                                  child: Center(
                                    child: ExcludeSemantics(
                                      child: AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        style: TextStyle(
                                            fontSize: selected ? 40 : 28),
                                        child: Text(mood.$2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(moodOptions[_selected].$1,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 28),
            if (widget.error != null) ...[
              Semantics(
                liveRegion: true,
                child:
                    Text(widget.error!, style: TextStyle(color: colors.error)),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: const StadiumBorder(),
              ),
              onPressed: widget.isSaving
                  ? null
                  : () => widget.onConfirm(moodOptions[_selected].$1),
              child: widget.isSaving
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, semanticsLabel: 'Saving mood'),
                    )
                  : const Text('Save my mood'),
            ),
          ],
        ),
      ),
    );
  }
}
