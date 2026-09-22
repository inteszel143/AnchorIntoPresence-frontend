import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The shared onboarding-inspired backdrop for app pages.
/// Paint it per route so one screen never shows through another during navigation.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    this.textureContrast = 1,
    this.bottomClouds = false,
  });

  /// Mirror the top clouds at full strength along the bottom of onboarding.
  final bool bottomClouds;

  /// Keep existing routes unchanged; onboarding can emphasize pale clouds.
  final double textureContrast;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix([
              textureContrast,
              0,
              0,
              0,
              255 * (1 - textureContrast),
              0,
              textureContrast,
              0,
              0,
              255 * (1 - textureContrast),
              0,
              0,
              textureContrast,
              0,
              255 * (1 - textureContrast),
              0,
              0,
              0,
              1,
              0,
            ]),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/app-background-${dark ? 'dark' : 'light'}.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                if (bottomClouds)
                  ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white,
                      ],
                      stops: [.45, .55],
                    ).createShader(bounds),
                    child: Transform.flip(
                      flipY: true,
                      child: Image.asset(
                        'assets/images/app-background-${dark ? 'dark' : 'light'}.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A standard Scaffold over the shared light/dark textured background.
/// Cards, fields and other foreground surfaces keep their existing styles.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: AppBackground()),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar,
            body: body,
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButton: floatingActionButton,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            extendBody: extendBody,
            extendBodyBehindAppBar: extendBodyBehindAppBar,
          ),
        ],
      ),
    );
  }
}
