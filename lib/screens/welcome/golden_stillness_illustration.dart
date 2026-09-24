import 'package:flutter/material.dart';

/// Gold petals with uniform opacity over the shared cloud background.
class GoldenStillnessIllustration extends StatelessWidget {
  const GoldenStillnessIllustration({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(top: height * .15),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: .8,
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
      );
}
