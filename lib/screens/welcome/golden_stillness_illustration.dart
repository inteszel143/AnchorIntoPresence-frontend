import 'package:flutter/material.dart';

/// Hazy, interrupted petals let the shared clouds cover the mandala.
class GoldenStillnessIllustration extends StatelessWidget {
  const GoldenStillnessIllustration({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: EdgeInsets.only(top: height * .15),
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: .8,
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      // Keep a gentle cloud
                      // veil across one band instead of dissolving the whole shape.
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xCCFFFFFF),
                          Colors.white,
                          Color(0xB3FFFFFF),
                          Color(0x80FFFFFF),
                          Colors.white,
                          Color(0xCCFFFFFF),
                        ],
                        stops: [0, .24, .43, .57, .74, 1],
                      ).createShader(bounds),
                      child: Image.asset(
                        Theme.of(context).brightness == Brightness.light
                            ? 'assets/images/onboarding/onboarding-mandala-subtle-light.png'
                            : 'assets/images/onboarding/onboarding-mandala-subtle.png',
                        fit: BoxFit.contain,
                        opacity: AlwaysStoppedAnimation<double>(
                          Theme.of(context).brightness == Brightness.light
                              ? 0.30
                              : 0.15,
                        ),
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),
              // An onboarding-only foreground bank of clouds softens the
              // lower petals without changing the shared app background.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height * .36,
                child: IgnorePointer(
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xCCFFFFFF),
                        Color(0xCCFFFFFF),
                        Colors.transparent,
                      ],
                      stops: [0, .3, .65, 1],
                    ).createShader(bounds),
                    child: Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/images/app-background-dark.png'
                          : 'assets/images/app-background-light.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
