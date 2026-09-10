import 'package:flutter/material.dart';
import 'custom_appbar.dart';
import 'scroll_title_page.dart';

/// Shared layout for support and document pages, using the app's title behavior.
class InformationPage extends StatelessWidget {
  const InformationPage(
      {super.key, required this.title, required this.slivers});

  final String title;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ScrollTitlePage(
          title: title,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  const CustomAppbar(headingTxt: ''),
                  Expanded(
                    child: CustomScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 24),
                            child: Text(title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        ...slivers,
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}
