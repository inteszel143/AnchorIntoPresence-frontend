import 'package:flutter/material.dart';

class MembershipBanner extends StatelessWidget {
  const MembershipBanner({
    super.key,
    required this.onExplore,
    required this.onDismiss,
  });

  final VoidCallback onExplore;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Material(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final button = FilledButton(
                      onPressed: onExplore,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: const Text('Explore'),
                    );
                    final message = Text(
                      'Explore membership and make space for your daily practice.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onPrimaryContainer,
                            height: 1.4,
                          ),
                    );
                    if (constraints.maxWidth < 280 ||
                        MediaQuery.textScalerOf(context).scale(14) > 20) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [message, const SizedBox(height: 8), button],
                      );
                    }
                    return Row(children: [
                      button,
                      const SizedBox(width: 12),
                      Expanded(child: message),
                    ]);
                  }),
                ),
                IconButton(
                  tooltip: 'Dismiss membership banner',
                  onPressed: onDismiss,
                  color: colors.onPrimaryContainer,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
