import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/local_storage.dart';
import '../../common/main_screen.dart';
import '../../utils/fonts.dart';
import '../account/account_screen.dart';

/// The illustrated welcome is separate so the original design stays restorable.
class IllustratedWelcomeScreen extends StatefulWidget {
  const IllustratedWelcomeScreen({super.key});

  @override
  State<IllustratedWelcomeScreen> createState() =>
      _IllustratedWelcomeScreenState();
}

class _IllustratedWelcomeScreenState extends State<IllustratedWelcomeScreen> {
  static const _pages = [
    (
      illustration: 'calm',
      title: 'Find your calm',
      description:
          'Slow down with guided meditations.\nTake a breath and come back to the present.',
    ),
    (
      illustration: 'rest',
      title: 'Make room for rest',
      description:
          'Let the busy moments soften.\nCreate a little space to pause and unwind.',
    ),
    (
      illustration: 'connection',
      title: 'Feel more connected',
      description:
          'Check in with yourself and grow together.\nSmall steps toward a more mindful day.',
    ),
  ];

  final _controller = PageController();
  int _index = 0;
  bool _opening = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(index,
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  Future<void> _start() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final token = await LocalStorage.getToken();
      if (!mounted) return;
      if (token != null && token.isNotEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
              builder: (_) => const MainScreen(initialIndex: 0)),
          (_) => false,
        );
      } else {
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => const AccountOnboardingScreen(),
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Unable to continue right now. Please try again.'),
        ));
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastPage = _index == _pages.length - 1;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colors.surface,
      ),
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: _pages.length,
                          onPageChanged: (index) =>
                              setState(() => _index = index),
                          itemBuilder: (context, index) {
                            final page = _pages[index];
                            return LayoutBuilder(
                                builder: (context, constraints) {
                              final illustrationHeight =
                                  (constraints.maxHeight * .76)
                                      .clamp(180.0, 560.0);
                              return SingleChildScrollView(
                                key: PageStorageKey('welcome-page-$index'),
                                child: Column(
                                  children: [
                                    ExcludeSemantics(
                                      // Blend the artwork's baked-in background
                                      // into the active surface in both themes.
                                      child: ShaderMask(
                                        blendMode: BlendMode.dstIn,
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white,
                                            Colors.white,
                                            Colors.transparent,
                                          ],
                                          stops: [0, .76, 1],
                                        ).createShader(bounds),
                                        child: Image.asset(
                                          'assets/images/onboarding/${page.illustration}-${dark ? 'dark' : 'light'}.png',
                                          width: constraints.maxWidth,
                                          height: illustrationHeight,
                                          fit: constraints.maxWidth >
                                                  illustrationHeight * 1.2
                                              ? BoxFit.contain
                                              : BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 18, 24, 24),
                                      child: Column(children: [
                                        Semantics(
                                          header: true,
                                          child: Text(
                                            page.title,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: Fonts.heading,
                                              fontSize: 27,
                                              height: 1.25,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -.8,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          page.description,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: Fonts.body,
                                            fontSize: 15,
                                            height: 1.7,
                                            color: colors.onSurface,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ],
                                ),
                              );
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: Row(
                          children: [
                            if (!lastPage) ...[
                              Semantics(
                                label: 'Page ${_index + 1} of ${_pages.length}',
                                child: ExcludeSemantics(
                                  child: Row(
                                      children: List.generate(
                                    _pages.length,
                                    (index) => AnimatedContainer(
                                      duration: MediaQuery.disableAnimationsOf(
                                              context)
                                          ? Duration.zero
                                          : const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 8),
                                      width: index == _index ? 24 : 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: index == _index
                                            ? colors.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                            color: colors.primary
                                                .withValues(alpha: .65)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )),
                                ),
                              ),
                              const Spacer(),
                            ],
                            Expanded(
                              flex: lastPage ? 1 : 2,
                              child: FilledButton(
                                onPressed: _opening
                                    ? null
                                    : lastPage
                                        ? _start
                                        : () => _goTo(_index + 1),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  disabledBackgroundColor:
                                      colors.onSurface.withValues(alpha: .12),
                                  disabledForegroundColor:
                                      colors.onSurface.withValues(alpha: .38),
                                  minimumSize: const Size(0, 52),
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                      fontFamily: Fonts.body,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(_opening
                                      ? 'Opening…'
                                      : lastPage
                                          ? 'Start'
                                          : 'Next'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          12, MediaQuery.paddingOf(context).top + 8, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_index > 0)
                            IconButton(
                              tooltip: 'Previous page',
                              onPressed:
                                  _opening ? null : () => _goTo(_index - 1),
                              icon: Icon(Icons.chevron_left_rounded,
                                  color: colors.onSurface),
                            )
                          else
                            const SizedBox(width: 48, height: 48),
                          if (!lastPage)
                            TextButton(
                              onPressed: _opening ? null : _start,
                              style: TextButton.styleFrom(
                                  foregroundColor: colors.onSurface),
                              child: const Text('Skip'),
                            )
                          else
                            const SizedBox(width: 48, height: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
