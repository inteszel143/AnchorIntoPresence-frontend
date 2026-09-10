import 'package:flutter/material.dart';

/// Keeps a page's large title available to its fixed header while scrolling.
/// Use around a fixed CustomAppbar and an Expanded vertical scroll view.
class ScrollTitlePage extends StatefulWidget {
  const ScrollTitlePage({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  static ValueNotifier<bool>? visibilityOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ScrollTitleScope>()
      ?.visibility;

  static String titleOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ScrollTitleScope>()?.title ??
      '';

  @override
  State<ScrollTitlePage> createState() => _ScrollTitlePageState();
}

class _ScrollTitlePageState extends State<ScrollTitlePage> {
  final _visibility = ValueNotifier(false);

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth == 0 && notification.metrics.axis == Axis.vertical) {
      _visibility.value = notification.metrics.pixels > 8;
    }
    return false;
  }

  @override
  void dispose() {
    _visibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ScrollTitleScope(
        title: widget.title,
        visibility: _visibility,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: SafeArea(child: widget.child),
        ),
      );
}

class _ScrollTitleScope extends InheritedWidget {
  const _ScrollTitleScope({
    required this.title,
    required this.visibility,
    required super.child,
  });

  final String title;
  final ValueNotifier<bool> visibility;

  @override
  bool updateShouldNotify(_ScrollTitleScope oldWidget) =>
      title != oldWidget.title || visibility != oldWidget.visibility;
}
