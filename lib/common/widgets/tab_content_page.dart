import 'package:flutter/material.dart';
import 'scroll_title_page.dart';

/// Shared spacious tab layout with a compact title that appears on scroll.
class TabContentPage extends StatelessWidget {
  const TabContentPage(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.slivers,
      this.action,
      this.bottomAction});
  final String title;
  final String subtitle;
  final List<Widget> slivers;
  final Widget? action;
  final Widget? bottomAction;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: ScrollTitlePage(
            title: title,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Builder(
                    builder: (context) => Stack(children: [
                          Column(children: [
                            SizedBox(
                                height: 56,
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 72),
                                          child: ValueListenableBuilder<bool>(
                                            valueListenable:
                                                ScrollTitlePage.visibilityOf(
                                                    context)!,
                                            builder: (_, visible, child) =>
                                                AnimatedOpacity(
                                                    opacity: visible ? 1 : 0,
                                                    duration: const Duration(
                                                        milliseconds: 180),
                                                    child: child),
                                            child: Text(title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700)),
                                          )),
                                      if (action != null)
                                        Positioned(right: 12, child: action!),
                                    ])),
                            Expanded(
                                child: CustomScrollView(slivers: [
                              SliverPadding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 8, 20, 26),
                                  sliver: SliverToBoxAdapter(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        Text(subtitle,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant)),
                                      ]))),
                              ...slivers,
                              SliverToBoxAdapter(
                                  child: SizedBox(
                                      height: bottomAction != null ? 88 : 32)),
                            ])),
                          ]),
                          if (bottomAction != null)
                            Positioned(
                                right: 20, bottom: 16, child: bottomAction!),
                        ])),
              ),
            )),
      );
}
