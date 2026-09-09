import 'fonts.dart';
// lib/utils/html_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

/// Inserts zero-width spaces at natural break points (after @ . / -)
/// inside long unbreakable strings like emails and URLs.
///
/// flutter_html lays out inline content (like an <a> tag's text) as a
/// single unbreakable run when it contains no spaces. On some devices the
/// available line width isn't enough to fit that whole run, and instead of
/// wrapping it cleanly, flutter_html's inline layout reflows the run (and
/// anything after it) out of order — which is what was causing "Website: ..."
/// to render above "tina@tinamoore.com" only on certain screen widths.
/// Giving the layout engine valid break points inside the string lets it
/// wrap normally instead of hitting that reflow path.
String _addWrapBreakpoints(String text) {
  final urlOrEmail = RegExp(
    r'(https?://[^\s<]+)|([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})',
  );
  return text.replaceAllMapped(urlOrEmail, (match) {
    final matched = match.group(0)!;
    return matched.replaceAllMapped(
      RegExp(r'([@./_-])'),
      (c) => '${c.group(1)}\u200B',
    );
  });
}

/// Sanitizes HTML text to fix word wrapping issues while preserving ALL formatting
String sanitizeHtmlText(String raw) {
  // Step 1: Replace &nbsp; with regular space (for better wrapping)
  String processed = raw.replaceAll('&nbsp;', ' ');

  // Step 2: Remove zero-width characters
  processed = processed
      .replaceAll('\u200B', '')
      .replaceAll('\u200C', '')
      .replaceAll('\u200D', '')
      .replaceAll('\uFEFF', '');

  // Step 3: Normalize line endings
  processed = processed.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  // Step 4: Fix broken paragraphs - combine consecutive <p> tags that are actually one paragraph
  // First, extract all content
  final List<String> parts = [];
  final RegExp tagRegex = RegExp(r'(<[^>]+>|[^<]+)');
  final matches = tagRegex.allMatches(processed);

  for (final match in matches) {
    parts.add(match.group(0)!);
  }

  // Rebuild with proper structure
  final buffer = StringBuffer();
  bool inParagraph = false;
  String currentParagraph = '';
  bool isInStrong = false;
  bool isInList = false;
  bool isInListItem = false;

  for (int i = 0; i < parts.length; i++) {
    final part = parts[i];

    // Check if it's an opening or closing tag
    if (part.startsWith('<')) {
      if (part == '<p>') {
        // Start a new paragraph
        if (currentParagraph.isNotEmpty) {
          // Close previous paragraph
          if (isInStrong) {
            buffer.write('</strong>');
            isInStrong = false;
          }
          buffer.write('</p>');
          currentParagraph = '';
        }
        buffer.write('<p>');
        inParagraph = true;
      } else if (part == '</p>') {
        // Close paragraph only if we're not in the middle of content
        if (inParagraph) {
          if (isInStrong) {
            buffer.write('</strong>');
            isInStrong = false;
          }
          buffer.write('</p>');
          inParagraph = false;
        }
      } else if (part.startsWith('<strong>') || part.startsWith('<b>')) {
        // Keep strong/bold tags
        if (isInStrong) {
          buffer.write('</strong>');
        }
        buffer.write(part);
        isInStrong = true;
      } else if (part.startsWith('</strong>') || part.startsWith('</b>')) {
        if (isInStrong) {
          buffer.write(part);
          isInStrong = false;
        }
      } else if (part == '<ul>' || part == '<ol>') {
        isInList = true;
        buffer.write(part);
      } else if (part == '</ul>' || part == '</ol>') {
        isInList = false;
        buffer.write(part);
      } else if (part == '<li>') {
        isInListItem = true;
        buffer.write(part);
      } else if (part == '</li>') {
        isInListItem = false;
        buffer.write(part);
      } else if (part.startsWith('<a ') || part == '<a>') {
        // Anchor tags are inline content (e.g. "Email: <a>...</a>") —
        // never close the surrounding paragraph for these, or the
        // link gets detached from its sentence and reflows on its own.
        buffer.write(part);
      } else if (part.startsWith('<') && !part.startsWith('</')) {
        // Other opening tags (h1, h2, h3, etc.)
        if (inParagraph) {
          if (isInStrong) {
            buffer.write('</strong>');
            isInStrong = false;
          }
          buffer.write('</p>');
          inParagraph = false;
        }
        buffer.write(part);
      } else if (part.startsWith('</') && part != '</p>') {
        // Other closing tags
        buffer.write(part);
      } else {
        // Unknown tag
        buffer.write(part);
      }
    } else {
      // It's text content
      final text = part.trim();
      if (text.isNotEmpty) {
        buffer.write(' ${_addWrapBreakpoints(text)}');
      }
    }
  }

  // Close any open tags
  if (inParagraph) {
    if (isInStrong) {
      buffer.write('</strong>');
    }
    buffer.write('</p>');
  }

  return buffer.toString();
}

/// Get common HTML styles for the app
Map<String, Style> getCommonHtmlStyles({
  required String fontFamily,
  required Color textColor,
  double fontSize = 14,
}) {
  return {
    "body": Style(
      fontSize: FontSize(fontSize),
      fontWeight: FontWeight.w400,
      fontFamily: fontFamily,
      color: textColor,
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      whiteSpace: WhiteSpace.normal,
      maxLines: null,
      textAlign: TextAlign.left,
    ),
    "h1": Style(
      fontSize: FontSize(22),
      fontWeight: FontWeight.bold,
      fontFamily: Fonts.heading,
      letterSpacing: Fonts.headingLetterSpacing,
      color: textColor,
      margin: Margins.only(top: 16, bottom: 8),
      whiteSpace: WhiteSpace.normal,
      maxLines: null,
      textAlign: TextAlign.left,
    ),
    "h2": Style(
      fontSize: FontSize(18),
      fontWeight: FontWeight.bold,
      fontFamily: Fonts.heading,
      letterSpacing: Fonts.headingLetterSpacing,
      color: textColor,
      margin: Margins.only(top: 14, bottom: 6),
      whiteSpace: WhiteSpace.normal,
      maxLines: null,
      textAlign: TextAlign.left,
    ),
    "h3": Style(
      fontSize: FontSize(16),
      fontWeight: FontWeight.w600,
      fontFamily: Fonts.heading,
      letterSpacing: Fonts.headingLetterSpacing,
      color: textColor,
      margin: Margins.only(top: 12, bottom: 4),
      whiteSpace: WhiteSpace.normal,
      maxLines: null,
      textAlign: TextAlign.left,
    ),
    "p": Style(
      fontSize: FontSize(fontSize),
      fontWeight: FontWeight.w400,
      fontFamily: fontFamily,
      color: textColor,
      lineHeight: LineHeight(1.6),
      margin: Margins.only(bottom: 8),
      padding: HtmlPaddings.zero,
      whiteSpace: WhiteSpace.normal,
      maxLines: null,
      textAlign: TextAlign.left,
    ),
    "ul": Style(
      margin: Margins.only(left: 16, bottom: 8),
      padding: HtmlPaddings.zero,
    ),
    "ol": Style(
      margin: Margins.only(left: 16, bottom: 8),
      padding: HtmlPaddings.zero,
    ),
    "li": Style(
      fontSize: FontSize(fontSize),
      fontFamily: fontFamily,
      color: textColor,
      lineHeight: LineHeight(1.6),
      margin: Margins.only(bottom: 4),
      padding: HtmlPaddings.zero,
      whiteSpace: WhiteSpace.normal,
      maxLines: null,
      textAlign: TextAlign.left,
    ),
    "strong": Style(
      fontWeight: FontWeight.bold,
    ),
    "b": Style(
      fontWeight: FontWeight.bold,
    ),
    "em": Style(
      fontStyle: FontStyle.italic,
    ),
    "i": Style(
      fontStyle: FontStyle.italic,
    ),
    "a": Style(
      color: Colors.blue,
      textDecoration: TextDecoration.underline,
    ),
  };
}
