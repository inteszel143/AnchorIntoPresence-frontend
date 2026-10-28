import 'package:flutter/material.dart';

/// Shared portrait artwork used by the Library and home practice collections.
class PracticeArtworkCard extends StatelessWidget {
  const PracticeArtworkCard({
    super.key,
    required this.title,
    required this.categoryLabel,
    required this.imageUrl,
    required this.onTap,
    this.isDailyPause = false,
    this.isFavorite = false,
    this.onFavorite,
  });

  final String title, categoryLabel, imageUrl;
  final VoidCallback onTap;
  final bool isDailyPause, isFavorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: '$title, $categoryLabel',
      button: true,
      child: Material(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          if (imageUrl.isNotEmpty)
            Image.network(imageUrl,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, __, ___) => _fallback(colors))
          else
            _fallback(colors),
          // The reference uses a dark scrim to keep editable titles readable.
          const DecoratedBox(
              decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, .4, 1],
              colors: [Color(0x16000000), Color(0x00000000), Color(0xE6000000)],
            ),
          )),
          Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap),
          ),
          Positioned(
            top: 14,
            left: 14,
            right: onFavorite == null ? 14 : 54,
            child: IgnorePointer(
                child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0x99000000),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                      isDailyPause
                          ? Icons.spa_outlined
                          : Icons.self_improvement_rounded,
                      color: Colors.white,
                      size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                      child: Text(
                    (categoryLabel.isEmpty ? 'Practice' : categoryLabel)
                        .toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .3),
                  )),
                ]),
              ),
            )),
          ),
          if (onFavorite != null)
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                tooltip: isFavorite ? 'Remove from favorites' : 'Save practice',
                style: IconButton.styleFrom(
                    backgroundColor: const Color(0x99000000),
                    foregroundColor: Colors.white),
                icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20),
                onPressed: onFavorite,
              ),
            ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 20,
            child: IgnorePointer(
                child: Text(
              title,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
            )),
          ),
        ]),
      ),
    );
  }

  Widget _fallback(ColorScheme colors) => ColoredBox(
        color: colors.secondaryContainer,
        child: Center(
            child: Icon(Icons.spa_outlined,
                size: 48, color: colors.onSecondaryContainer)),
      );
}
