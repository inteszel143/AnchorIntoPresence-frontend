import 'package:flutter/material.dart';

class FAQItemTile extends StatelessWidget {
  const FAQItemTile({super.key, required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colors.surfaceContainerHighest,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: shape,
          collapsedShape: shape,
          iconColor: colors.primary,
          collapsedIconColor: colors.onSurfaceVariant,
          title: Text(question,
              style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4)),
          children: [
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: 16),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(answer,
                    style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 15,
                        height: 1.6))),
          ],
        ),
      ),
    );
  }
}
