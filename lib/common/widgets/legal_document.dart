import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../utils/fonts.dart';
import '../../utils/html_utils.dart';

/// Presents the existing document content with consistent reading typography.
class LegalDocument extends StatelessWidget {
  const LegalDocument({super.key, required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styles = getCommonHtmlStyles(
      fontFamily: Fonts.body,
      textColor: colors.onSurface,
      fontSize: 15,
    );
    styles['body'] =
        styles['body']!.copyWith(lineHeight: const LineHeight(1.65));
    styles['p'] = (styles['p'] ?? Style()).copyWith(
      lineHeight: const LineHeight(1.65),
      margin: Margins.only(bottom: 16),
    );
    styles['a'] = (styles['a'] ?? Style()).copyWith(color: colors.primary);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Html(
          data: sanitizeHtmlText(description), style: styles, shrinkWrap: true),
    );
  }
}
