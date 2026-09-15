import 'package:flutter/material.dart';

/// Frames the watercolor suns with a quiet shoreline and coastal palms.
class BeachIllustration extends StatelessWidget {
  const BeachIllustration({
    super.key,
    required this.asset,
    required this.height,
  });

  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white, Colors.transparent],
            stops: [0, .86, 1],
          ).createShader(bounds),
          child: LayoutBuilder(builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  asset,
                  fit: constraints.maxWidth > height * 1.2
                      ? BoxFit.contain
                      : BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                IgnorePointer(
                  child: CustomPaint(painter: _ShorePainter(dark: dark)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ShorePainter extends CustomPainter {
  const _ShorePainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    // A shared coordinate system anchors the shoreline and palms to the
    // illustration area at every screen size.
    canvas.save();
    canvas.scale(size.width / 390, size.height / 500);
    final sand = dark ? const Color(0xFF8C7862) : const Color(0xFFE6CDA8);
    final shore = Path()
      ..moveTo(0, 405)
      ..cubicTo(75, 385, 125, 440, 210, 420)
      ..cubicTo(280, 400, 335, 392, 390, 410)
      ..lineTo(390, 500)
      ..lineTo(0, 500)
      ..close();
    canvas.drawPath(
      shore,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sand.withValues(alpha: .05), sand.withValues(alpha: .6)],
        ).createShader(const Rect.fromLTWH(0, 385, 390, 115)),
    );
    final foam = Path()
      ..moveTo(0, 405)
      ..cubicTo(75, 385, 125, 440, 210, 420)
      ..cubicTo(280, 400, 335, 392, 390, 410);
    canvas.drawPath(
      foam,
      Paint()
        ..color = (dark ? sand : Colors.white).withValues(alpha: .4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    _palm(canvas, const Offset(38, 437), 1, false);
    _palm(canvas, const Offset(351, 441), .78, true);
    canvas.restore();
  }

  void _palm(Canvas canvas, Offset base, double scale, bool mirrored) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.scale(mirrored ? -scale : scale, scale);
    final leaf = dark ? const Color(0xFF899A7E) : const Color(0xFF7C947B);
    final trunk = dark ? const Color(0xFFA18C73) : const Color(0xFFB19A7B);
    canvas.drawOval(
      const Rect.fromLTWH(-24, -3, 55, 7),
      Paint()..color = trunk.withValues(alpha: .14),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-3, 0)
        ..quadraticBezierTo(8, -47, 0, -98)
        ..quadraticBezierTo(19, -53, 4, 0)
        ..close(),
      Paint()..color = trunk.withValues(alpha: .8),
    );
    for (final tip in const [
      Offset(-41, -77),
      Offset(-44, -105),
      Offset(-23, -124),
      Offset(15, -126),
      Offset(44, -105),
      Offset(39, -78),
    ]) {
      final frond = Path()
        ..moveTo(0, -98)
        ..quadraticBezierTo(tip.dx * .5, tip.dy - 19, tip.dx, tip.dy)
        ..quadraticBezierTo(tip.dx * .48, tip.dy - 4, 0, -98)
        ..close();
      canvas.drawPath(frond, Paint()..color = leaf.withValues(alpha: .8));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShorePainter oldDelegate) =>
      oldDelegate.dark != dark;
}
