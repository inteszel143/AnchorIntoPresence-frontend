import 'package:flutter/material.dart';
import 'custom_appbar.dart';
import 'scroll_title_page.dart';

/// Shared layout for the Home tab's saved content and updates.
class CollectionPage extends StatelessWidget {
  const CollectionPage(
      {super.key,
      required this.title,
      required this.description,
      required this.slivers,
      this.onRefresh});
  final String title, description;
  final List<Widget> slivers;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ScrollTitlePage(
        title: title,
        child: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              CustomAppbar(
                  headingTxt: '',
                  okimage: onRefresh == null
                      ? null
                      : Tooltip(
                          message: 'Refresh ${title.toLowerCase()}',
                          child: const Icon(Icons.refresh_rounded)),
                  onOkTap: onRefresh),
              Expanded(
                  child: CustomScrollView(slivers: [
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: theme.textTheme.headlineLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.6)),
                      ]),
                )),
                ...slivers,
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ])),
            ]),
          ),
        )),
      ),
    );
  }
}

class CollectionMessage extends StatelessWidget {
  const CollectionMessage(
      {super.key,
      required this.icon,
      required this.title,
      required this.description,
      this.action});
  final IconData icon;
  final String title, description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24)),
      child: Column(children: [
        Icon(icon, size: 36, color: theme.colorScheme.primary),
        const SizedBox(height: 20),
        Text(title,
            textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant, height: 1.6)),
        if (action != null) ...[const SizedBox(height: 24), action!],
      ]),
    );
  }
}
